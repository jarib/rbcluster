#include <assert.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "ruby.h"
#include "cluster.h"

VALUE Cluster = Qnil;

VALUE rbcluster_data2rb(double** data, int nrows, int ncols) {
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
  int rows, cols;

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
      rb_raise(rb_eArgError, "expected %d columns, row has %ld", cols, RARRAY_LEN(row));
    }

    for(j = 0; j < cols; ++j) {
      result[i][j] = NUM2DBL(rb_ary_entry(row, j));
    }
  }

  *nrows = rows;
  *ncols = cols;

  return result;
}

void rbcluster_free_doubles(double** data, int nrows) {
  int i;
  for(i = 0; i < nrows; ++i) {
    free(data[i]);
  }

  free(data);
}

void rbcluster_free_mask(int** mask, int nrows) {
  int i;

  for(i = 0; i < nrows; ++i) {
    free(mask[i]);
  }
  free(mask);
}

VALUE rbcluster_ints2rb(int* ints, long rows) {
  VALUE ary = rb_ary_new2(rows);
  int i;
  for(i = 0; i < rows; ++i) {
    rb_ary_push(ary, INT2FIX(ints[i]));
  }

  return ary;
}

/*
  TODO: docs.

  ‘c’	Pearson correlation coefficient;
  ‘a’	Absolute value of the Pearson correlation coefficient;
  ‘u’	Uncentered Pearson correlation (equivalent to the cosine of the angle between two data vectors);
  ‘x’	Absolute uncentered Pearson correlation; ‘s’	Spearman’s rank correlation; ‘k’	Kendall’s	τ ; ‘e’	Euclidean distance;
  ‘b’	City-block distance.
*/

VALUE rbcluster_kcluster(int argc, VALUE* argv, VALUE self) {
  VALUE arr, opts;

  rb_scan_args(argc, argv, "11", &arr, &opts);

  int nrows, ncols;
  double** data = rbcluster_ary_to_rows(arr, &nrows, &ncols);
  int** mask = malloc(nrows*sizeof(int*));

  int i, n;
  for(i = 0; i < nrows; ++i) {
    mask[i] = malloc(ncols*sizeof(int));
    for(n = 0; n < ncols; ++n) {
      mask[i][n] = 1;
    }
  }

  // defaults
  int nclusters = 2;
  int transpose = 0;
  int npass = 1;
  int ifound = 0;
  double error;
  char method = 'a';
  char dist = 'e';

  double* weight = malloc(ncols*sizeof(double));
  int* clusterid = malloc(nrows*sizeof(int));

  for (i = 0; i < ncols; i++)
    weight[i] = 1.0;

  // options
  if(opts != Qnil) {
    Check_Type(opts, T_HASH);
    VALUE val;

    val = rb_hash_aref(opts, ID2SYM(rb_intern("clusters")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_FIXNUM);
      nclusters = FIX2INT(val);
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("mask")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_ARRAY);
      VALUE row;

      for(i = 0; i < nrows; ++i) {
        row = rb_ary_entry(val, i);
        Check_Type(row, T_ARRAY);
        for(n = 0; n < ncols; ++n) {
          mask[i][n] = FIX2INT(rb_ary_entry(row, n));
        }
      }
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("weight")));
    if(TYPE(val) != Qnil) {
      free(weight);
      weight = rbcluster_ary_to_doubles(val, ncols);
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("transpose")));
    if(TYPE(val) != Qnil) {
      transpose = val ? 1 : 0;
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("passes")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_FIXNUM);
      npass = FIX2INT(val);
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("method")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_STRING);
      method = RSTRING_PTR(val)[0];
    }

    val = rb_hash_aref(opts, ID2SYM(rb_intern("dist")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_STRING);
      dist = RSTRING_PTR(val)[0];
    }
  }

  kcluster(nclusters, nrows, ncols, data, mask, weight,
    transpose, npass, method, dist, clusterid, &error, &ifound);

  VALUE result = rbcluster_ints2rb(clusterid, nrows);

  rbcluster_free_doubles(data, nrows);
  rbcluster_free_mask(mask, nrows);

  free(weight);
  free(clusterid);

  return rb_ary_new3(3, result, DBL2NUM(error), INT2NUM(ifound));
}

void Init_rbcluster() {
  Cluster = rb_define_module("Cluster");
  rb_define_singleton_method(Cluster, "kcluster", rbcluster_kcluster, -1);
}