#include <assert.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "ruby.h"
#include "cluster.h"

VALUE Cluster = Qnil;

VALUE rbcluster_rows2rb(double** data, int nrows, int ncols) {
  VALUE rows = rb_ary_new2((long)nrows);
  VALUE cols;
  int i, j;

  for(i = 0; i < nrows; ++i) {
    cols = rb_ary_new2((long)ncols);
    rb_ary_push(rows, cols);
    for(j = 0; j < ncols; ++j) {
      rb_ary_push(cols, rb_float_new(data[i][j]));
    }
  }

  return rows;
}

double* rbcluster_ary_to_doubles(VALUE data, int len) {
  Check_Type(data, T_ARRAY);

  if(RARRAY_LEN(data) != len) {
    rb_raise(rb_eArgError, "expected Array to have %d entries, got %ld", len, RARRAY_LEN(data));
  }

  double* result = malloc(len*sizeof(double));
  int i;
  for(i = 0; i < len; ++i) {
    result[i] = NUM2DBL(rb_ary_entry(data, i));
  }

  return result;
}

double** rbcluster_ary_to_rows(VALUE data, int* nrows, int* ncols) {
  Check_Type(data, T_ARRAY);
  long rows, cols;

  rows = RARRAY_LEN(data);
  if(rows == 0) {
    rb_raise(rb_eArgError, "no data given");
  }

  VALUE first_element = rb_ary_entry(data, 0);
  Check_Type(first_element, T_ARRAY);
  cols = RARRAY_LEN(first_element);

  double** result = malloc((rows)*sizeof(double*));

  VALUE row;
  int i, j;

  for(i = 0; i < rows; ++i) {
    result[i] = malloc((cols)*sizeof(double));
    row = rb_ary_entry(data, i);

    Check_Type(row, T_ARRAY);
    if(RARRAY_LEN(row) != cols) {
      rb_raise(rb_eArgError, "expected %ld columns, row has %ld", cols, RARRAY_LEN(row));
    }

    for(j = 0; j < cols; ++j) {
      result[i][j] = NUM2DBL(rb_ary_entry(row, j));
    }
  }

  *nrows = (int)rows;
  *ncols = (int)cols;

  return result;
}

void rbcluster_free_rows(double** data, int nrows) {
  for(int i = 0; i < nrows; ++i)
    free(data[i]);

  free(data);
}

int** rbcluster_create_mask(int nrows, int ncols) {
  int** mask = malloc(nrows*sizeof(int*));

  for(int i = 0; i < nrows; ++i) {
    mask[i] = malloc(ncols*sizeof(int));
    for(int n = 0; n < ncols; ++n) {
      mask[i][n] = 1;
    }
  }

  return mask;
}

void rbcluster_free_mask(int** mask, int nrows) {
  for(int i = 0; i < nrows; ++i)
    free(mask[i]);

  free(mask);
}

double* rbcluster_create_weight(int ncols) {
  double* weight = malloc(ncols*sizeof(double));

  for (int i = 0; i < ncols; i++)
    weight[i] = 1.0;

  return weight;
}

VALUE rbcluster_ints2rb(int* ints, long rows) {
  VALUE ary = rb_ary_new2(rows);

  for(int i = 0; i < rows; ++i) {
    rb_ary_push(ary, INT2FIX(ints[i]));
  }

  return ary;
}


/*
  option hash parsing
*/

void rbcluster_parse_mask(VALUE opts, int** mask, int nrows, int ncols) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern("mask")));

  if(NIL_P(val))
    return;

  // TODO: better error message
  Check_Type(val, T_ARRAY);
  VALUE row;
  int i, j;

  for(i = 0; i < nrows; ++i) {
    row = rb_ary_entry(val, i);
    Check_Type(row, T_ARRAY);
    for(j = 0; j < ncols; ++j) {
      mask[i][j] = FIX2INT(rb_ary_entry(row, j));
    }
  }
}

void rbcluster_parse_weight(VALUE opts, double** weight, int ncols) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern("weight")));

  if(val != Qnil) {
    free(*weight);
    *weight = rbcluster_ary_to_doubles(val, ncols);
  }
}

void rbcluster_parse_int(VALUE opts, const char* key, int* out) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern(key)));
  if(val != Qnil) {
    Check_Type(val, T_FIXNUM);
    *out = FIX2INT(val);
  }
}

void rbcluster_parse_char(VALUE opts, const char* key, char* out) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern(key)));
  if(val != Qnil) {
    Check_Type(val, T_STRING);
    *out = RSTRING_PTR(val)[0];
  }
}

void rbcluster_parse_bool(VALUE opts, const char* key, int* out) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern(key)));
  if(val != Qnil) {
    *out = val ? 1 : 0;
  }
}


/*
  main function
*/

VALUE rbcluster_kcluster(int argc, VALUE* argv, VALUE self) {
  VALUE arr, opts;
  int nrows, ncols, i, j;

  rb_scan_args(argc, argv, "11", &arr, &opts);

  double** data = rbcluster_ary_to_rows(arr, &nrows, &ncols);
  int** mask    = rbcluster_create_mask(nrows, ncols);

  // defaults
  int nclusters = 2;
  int transpose = 0;
  int npass     = 1;
  char method   = 'a';
  char dist     = 'e';
  double* weight = rbcluster_create_weight(nrows);

  int* clusterid = malloc(nrows*sizeof(int));
  int ifound    = 0;
  double error;

  // options
  if(opts != Qnil) {
    Check_Type(opts, T_HASH);
    VALUE val;

    rbcluster_parse_int(opts, "clusters", &nclusters);
    rbcluster_parse_mask(opts, mask, nrows, ncols);
    rbcluster_parse_weight(opts, &weight, ncols);
    rbcluster_parse_bool(opts, "transpose", &transpose);
    rbcluster_parse_int(opts, "passes", &npass);
    rbcluster_parse_char(opts, "method", &method);
    rbcluster_parse_char(opts, "dist", &dist);
  }

  kcluster(nclusters, nrows, ncols, data, mask, weight,
    transpose, npass, method, dist, clusterid, &error, &ifound);

  VALUE result = rbcluster_ints2rb(clusterid, nrows);

  rbcluster_free_rows(data, nrows);
  rbcluster_free_mask(mask, nrows);

  free(weight);
  free(clusterid);

  return rb_ary_new3(3, result, DBL2NUM(error), INT2NUM(ifound));
}

VALUE rbcluster_kmedoids(int argc, VALUE* argv, VALUE self) {
  VALUE data, opts;

  rb_scan_args(argc, argv, "11", &data, &opts);
  Check_Type(data, T_ARRAY);

  int nitems = (int)RARRAY_LEN(data);
  int nclusters = 2;
  int npass = 1;

  // populate 'distances' from the input Array
  double** distances = malloc(nitems*sizeof(double*));
  int i, j;
  VALUE row, num;

  for(i = 0; i < nitems; ++i) {
    row = rb_ary_entry(data, i);
    // TODO: better error message
    Check_Type(row, T_ARRAY);
    if(RARRAY_LEN(row) != i) {
      rb_raise(rb_eArgError,
        "expected row %d to have exactly %d elements, got %ld", i, i, RARRAY_LEN(row));
    }

    if(i == 0) {
      distances[i] = NULL;
    } else {
      distances[i] = malloc(i*sizeof(double));
    }

    for(j = 0; j < i; ++j) {
      distances[i][j] = NUM2DBL(rb_ary_entry(row, j));
    }
  }

  if(opts != Qnil) {
    rbcluster_parse_int(opts, "clusters", &nclusters);
    rbcluster_parse_int(opts, "passes", &npass);
    // TODO: initialid
  }

  int* clusterid = malloc(nitems*sizeof(int));
  double error;
  int ifound;

  // void kmedoids (int nclusters, int nelements, double** distance,
  //   int npass, int clusterid[], double* error, int* ifound);
  kmedoids(nclusters, nitems, distances, npass, clusterid, &error, &ifound);

  VALUE result = rbcluster_ints2rb(clusterid, nitems);
  free(clusterid);
  for(i = 1; i < nitems; ++i) free(distances[i]);

  return rb_ary_new3(3, result, DBL2NUM(error), INT2NUM(ifound));
}

VALUE rbcluster_median(VALUE self, VALUE ary) {
  Check_Type(ary, T_ARRAY);

  long len = RARRAY_LEN(ary);
  double arr[len];
  int i;
  VALUE num;

  for(i = 0; i < len; ++i) {
    num = rb_ary_entry(ary, i);
    arr[i] = NUM2DBL(num);
  }

  return DBL2NUM(median((int)len, arr));
}

VALUE rbcluster_mean(VALUE self, VALUE ary) {
  Check_Type(ary, T_ARRAY);

  long len = RARRAY_LEN(ary);
  double arr[len];
  int i;
  VALUE num;

  for(i = 0; i < len; ++i) {
    num = rb_ary_entry(ary, i);
    arr[i] = NUM2DBL(num);
  }

  return DBL2NUM(mean((int)len, arr));
}

VALUE rbcluster_distancematrix(int argc, VALUE* argv, VALUE self) {
  VALUE data, opts;
  int nrows, ncols, i, j;

  rb_scan_args(argc, argv, "11", &data, &opts);
  double** rows = rbcluster_ary_to_rows(data, &nrows, &ncols);

  char dist      = 'e';
  int transpose  = 0;
  int** mask     = rbcluster_create_mask(nrows, ncols);
  double* weight = rbcluster_create_weight(ncols);

  if(opts != Qnil) {
    Check_Type(opts, T_HASH);
    VALUE val;

    rbcluster_parse_mask(opts, mask, nrows, ncols);
    rbcluster_parse_weight(opts, &weight, ncols);
    rbcluster_parse_char(opts, "dist", &dist);
    rbcluster_parse_bool(opts, "transpose", &transpose);
  }

  VALUE result = Qnil;
  double** distances = distancematrix(
    nrows,
    ncols,
    rows,
    mask,
    weight,
    dist,
    transpose
  );

  if(distances) {
    result = rb_ary_new();
    for(i = 0; i < nrows; ++i) {
      VALUE row = rb_ary_new();

      for(j = 0; j < i; ++j){
        rb_ary_push(row, DBL2NUM(distances[i][j]));
      }

      // first row is NULL
      if(i != 0) {
        free(distances[i]);
      }

      rb_ary_push(result, row);
    }
  }

  free(weight);
  rbcluster_free_rows(rows, nrows);
  rbcluster_free_mask(mask, nrows);

  return result;
}

int* rbcluster_parse_index(VALUE arr, int* len) {
  Check_Type(arr, T_ARRAY);
  long length = RARRAY_LEN(arr);

  int* result = malloc(length*sizeof(int));

  for(int i = 0; i < length; ++i) {
    result[i] = FIX2INT(rb_ary_entry(arr, i));
  }

  *len = (int)length;
  return result;
}

VALUE rbcluster_clusterdistance(int argc, VALUE* argv, VALUE self) {
  VALUE data, index1, index2, opts;
  int nrows, ncols;

  rb_scan_args(argc, argv, "31", &data, &index1, &index2, &opts);
  double** rows = rbcluster_ary_to_rows(data, &nrows, &ncols);

  int nidx1, nidx2;
  int* idx1 = rbcluster_parse_index(index1, &nidx1);
  int* idx2 = rbcluster_parse_index(index2, &nidx2);

  int** mask = rbcluster_create_mask(nrows, ncols);
  double* weight = rbcluster_create_weight(ncols);
  char method = 'a';
  char dist = 'e';
  int transpose = 0;

  if(opts != Qnil) {
    rbcluster_parse_mask(opts, mask, nrows, ncols);
    rbcluster_parse_weight(opts, &weight, ncols);
    rbcluster_parse_char(opts, "dist", &dist);
    rbcluster_parse_char(opts, "method", &method);
    rbcluster_parse_bool(opts, "transpose", &transpose);
  }
  // options parsing


  double result = clusterdistance(
    nrows,
    ncols,
    rows,
    mask,
    weight,
    nidx1,
    nidx2,
    idx1,
    idx2,
    dist,
    method,
    transpose
  );

  free(weight);
  free(idx1);
  free(idx2);
  rbcluster_free_rows(rows, nrows);
  rbcluster_free_mask(mask, nrows);

  return DBL2NUM(result);
}

void Init_rbcluster() {
  Cluster = rb_define_module("Cluster");

  rb_define_singleton_method(Cluster, "median", rbcluster_median, 1);
  rb_define_singleton_method(Cluster, "mean", rbcluster_mean, 1);

  rb_define_singleton_method(Cluster, "kcluster", rbcluster_kcluster, -1);
  rb_define_singleton_method(Cluster, "distancematrix", rbcluster_distancematrix, -1);
  rb_define_singleton_method(Cluster, "kmedoids", rbcluster_kmedoids, -1);
  rb_define_singleton_method(Cluster, "clusterdistance", rbcluster_clusterdistance, -1);

  rb_define_const(Cluster, "C_VERSION", rb_str_new2(CLUSTERVERSION));
}