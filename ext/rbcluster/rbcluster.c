#include <stdlib.h>
#include <stdio.h>
#include "ruby.h"
#include "cluster.h"

// missing on 1.8
#ifndef DBL2NUM
#define DBL2NUM( dbl_val ) rb_float_new( dbl_val )
#endif

VALUE rbcluster_mCluster = Qnil;
VALUE rbcluster_cNode = Qnil;
VALUE rbcluster_cTree = Qnil;

VALUE rbcluster_rows2rb(double** data, int nrows, int ncols) {
  VALUE rows = rb_ary_new2((long)nrows);
  VALUE cols;
  int i, j;

  for(i = 0; i < nrows; ++i) {
    cols = rb_ary_new2((long)ncols);
    rb_ary_push(rows, cols);
    for(j = 0; j < ncols; ++j) {
      rb_ary_push(cols, DBL2NUM(data[i][j]));
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
  for(int i = 0; i < len; ++i) {
    result[i] = NUM2DBL(rb_ary_entry(data, i));
  }

  return result;
}

Node* rbcluster_ary_to_nodes(VALUE data, int* len) {
  Check_Type(data, T_ARRAY);

  long length = RARRAY_LEN(data);

  Node* result = (Node*)malloc(length*sizeof(Node));

  for(int i = 0; i < length; ++i)
  {
    VALUE node = rb_ary_entry(data, i);

    result[i].left = NUM2INT(rb_ivar_get(node, rb_intern("@left")));
    result[i].right = NUM2INT(rb_ivar_get(node, rb_intern("@right")));
    result[i].distance = NUM2DBL(rb_ivar_get(node, rb_intern("@distance")));
  }

  *len = (int)length;
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

VALUE rbcluster_ints2rb(int* ints, long nrows) {
  VALUE ary = rb_ary_new2(nrows);

  for(int i = 0; i < nrows; ++i) {
    rb_ary_push(ary, INT2FIX(ints[i]));
  }

  return ary;
}

VALUE rbcluster_doubles2rb(double* arr, long nrows) {
  VALUE ary = rb_ary_new2(nrows);

  for(int i = 0; i < nrows; ++i) {
    rb_ary_push(ary, DBL2NUM(arr[i]));
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

void rbcluster_parse_double(VALUE opts, const char* key, double* out) {
  VALUE val = rb_hash_aref(opts, ID2SYM(rb_intern(key)));
  if(val != Qnil) {
    Check_Type(val, T_FLOAT);
    *out = NUM2DBL(val);
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

  kcluster(
    nclusters,
    nrows,
    ncols,
    data,
    mask,
    weight,
    transpose,
    npass,
    method,
    dist,
    clusterid,
    &error,
    &ifound
  );

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
  kmedoids(
    nclusters,
    nitems,
    distances,
    npass,
    clusterid,
    &error,
    &ifound
  );

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

VALUE rbcluster_create_node(Node* node) {
  VALUE args[3];

  args[0] = INT2NUM(node->left);
  args[1] = INT2NUM(node->right);
  args[2] = DBL2NUM(node->distance);

  return rb_class_new_instance(3, args, rbcluster_cNode);
}

VALUE rbcluster_node_initialize(int argc, VALUE* argv, VALUE self) {
  VALUE left, right, distance;

  rb_scan_args(argc, argv, "21", &left, &right, &distance);

  if(NIL_P(distance)) {
    distance = DBL2NUM(0.0);
  }

  rb_ivar_set(self, rb_intern("@left"), left);
  rb_ivar_set(self, rb_intern("@right"), right);
  rb_ivar_set(self, rb_intern("@distance"), distance);

  return self;
}

double*** rbcluster_create_celldata(int nxgrid, int nygrid, int ndata) {
  double*** celldata = calloc(nxgrid*nygrid*ndata, sizeof(double**));
  int i, j;

  for (i = 0; i < nxgrid; i++)
  { celldata[i] = calloc(nygrid*ndata, sizeof(double*));
    for (j = 0; j < nygrid; j++)
      celldata[i][j] = calloc(ndata, sizeof(double));
  }

  return celldata;
}

void rbcluster_free_celldata(double*** celldata, int nxgrid, int nygrid) {
  int i, j;

  for (i = 0; i < nxgrid; i++) {
    for (j = 0; j < nygrid; j++) {
      free(celldata[i][j]);
    }
  }

  for (i = 0; i < nxgrid; i++)
    free(celldata[i]);

  free(celldata);
}

VALUE rbcluster_treecluster(int argc, VALUE* argv, VALUE self) {
  VALUE data, opts;
  rb_scan_args(argc, argv, "11", &data, &opts);

  int nrows, ncols;
  double** rows = rbcluster_ary_to_rows(data, &nrows, &ncols);

  int** mask     = rbcluster_create_mask(nrows, ncols);
  double* weight = rbcluster_create_weight(ncols);
  int transpose  = 0;
  char dist      = 'e';
  char method    = 'a';

   // TODO: allow passing a distance matrix instead of data.
  double** distmatrix = NULL;

  // options
  if(opts != Qnil) {
    rbcluster_parse_mask(opts, mask, nrows, ncols);
    rbcluster_parse_weight(opts, &weight, ncols);
    rbcluster_parse_char(opts, "dist", &dist);
    rbcluster_parse_char(opts, "method", &method);
    rbcluster_parse_bool(opts, "transpose", &transpose);

    if(TYPE(opts) == T_HASH && rb_hash_aref(opts, ID2SYM(rb_intern("distancematrix"))) != Qnil) {
      rb_raise(rb_eNotImpError, "passing a distance matrix to treecluster() is not yet implemented");
    }
  }

  Node* tree = treecluster(
    nrows,
    ncols,
    rows,
    mask,
    weight,
    transpose,
    dist,
    method,
    distmatrix
  );

  VALUE result = rb_ary_new2(nrows - 1);
  for(int i = 0; i < nrows - 1; ++i) {
    rb_ary_push(result, rbcluster_create_node(&tree[i]));
  }

  free(tree);
  free(weight);
  rbcluster_free_rows(rows, nrows);
  rbcluster_free_mask(mask, nrows);

  VALUE args[1] = { result, NULL };
  return rb_class_new_instance(1, args, rbcluster_cTree);
}

VALUE rbcluster_somcluster(int argc, VALUE* argv, VALUE self) {
  VALUE data, opts;

  rb_scan_args(argc, argv, "11", &data, &opts);

  int nrows, ncols;
  double** rows = rbcluster_ary_to_rows(data, &nrows, &ncols);
  int** mask = rbcluster_create_mask(nrows, ncols);
  double* weight = rbcluster_create_weight(ncols);

  int transpose  = 0;
  char dist      = 'e';
  int nxgrid     = 2;
  int nygrid     = 1;
  double inittau = 0.02;
  int niter      = 1;

  if(opts != Qnil) {
    rbcluster_parse_mask(opts, mask, nrows, ncols);
    rbcluster_parse_weight(opts, &weight, ncols);
    rbcluster_parse_bool(opts, "transpose", &transpose);
    rbcluster_parse_int(opts, "nxgrid", &nxgrid);
    rbcluster_parse_int(opts, "nygrid", &nygrid);
    rbcluster_parse_double(opts, "inittau", &inittau);
    rbcluster_parse_int(opts, "niter", &niter);
    rbcluster_parse_char(opts, "dist", &dist);
  }

  int i, j, k;
  double*** celldata = rbcluster_create_celldata(nygrid, nxgrid, ncols);

  int clusterid[nrows][2];

  somcluster(
    nrows,
    ncols,
    rows,
    mask,
    weight,
    transpose,
    nxgrid,
    nygrid,
    inittau,
    niter,
    dist,
    celldata,
    clusterid
  );

  VALUE rb_celldata = rb_ary_new2(nxgrid);
  VALUE rb_clusterid = rb_ary_new2(nrows);

  VALUE iarr, jarr;

  for(i = 0; i < nxgrid; ++i) {
    iarr = rb_ary_new2(nygrid);
    for(j = 0; j < nygrid; ++j) {
      jarr = rb_ary_new2(ncols);
      for(k = 0; k < ncols; ++k) {
        rb_ary_push(jarr, DBL2NUM(celldata[i][j][k]));
      }
      rb_ary_push(iarr, jarr);
    }
    rb_ary_push(rb_celldata, iarr);
  }

  VALUE inner_arr;
  for(i = 0; i < nrows; ++i) {
    inner_arr = rb_ary_new2(2);
    rb_ary_push(inner_arr, INT2FIX(clusterid[i][0]));
    rb_ary_push(inner_arr, INT2FIX(clusterid[i][1]));

    rb_ary_push(rb_clusterid, inner_arr);
  }

  free(weight);
  rbcluster_free_rows(rows, nrows);
  rbcluster_free_mask(mask, nrows);
  rbcluster_free_celldata(celldata, nxgrid, nygrid);

  return rb_ary_new3(2, rb_clusterid, rb_celldata);
}

void rbcluster_print_doubles(double* vals, int len) {
  puts("[");
  for(int i = 0; i < len; ++i) {
    printf("\t%d: %f\n", i, vals[i]);
  }
  puts("]");
}

void rbcluster_print_double_matrix(double** vals, int nrows, int ncols) {
  puts("[");
  for(int i = 0; i < nrows; ++i) {
    printf("\t[ ");
    for(int j = 0; j < ncols; ++j) {
      printf("%f%c", vals[i][j], j == ncols - 1 ? ' ' : ',');
    }
    printf("\t]\n");
  }
  puts("]");
}

VALUE rbcluster_pca(VALUE self, VALUE data) {
  int nrows, ncols, i, j;

  double** u = rbcluster_ary_to_rows(data, &nrows, &ncols);
  int ndata = min(nrows, ncols);

  double** v = malloc(ndata*sizeof(double*));
  for(i = 0; i < ndata; ++i) {
    v[i] = malloc(ndata*sizeof(double));
  }
  double* w = malloc(ndata*sizeof(double));
  double* means = malloc(ncols*sizeof(double));

  // calculate the mean of each column
  for(j = 0; j < ncols; ++j) {
    means[j] = 0.0;
    for(i = 0; i < nrows; ++i) {
      means[j] += u[i][j];
    }

    means[j] /= nrows;
  }

  // subtract the mean of each column
  for(i = 0; i < nrows; ++i) {
    for(j = 0; j < ncols; ++j) {
      u[i][j] = u[i][j] - means[j];
    }
  }

  int ok = pca(nrows, ncols, u, v, w);
  if(ok == -1) {
    rb_raise(rb_eNoMemError, "could not allocate memory");
  } else if(ok > 0) {
    rb_raise(rb_eStandardError, "svd failed to converge");
  }

  VALUE mean = rbcluster_doubles2rb(means, ncols);
  VALUE eigenvalues = rbcluster_doubles2rb(w, ndata);
  VALUE coordinates = Qnil;
  VALUE pc = Qnil;

  if(nrows >= ncols) {
    coordinates = rbcluster_rows2rb(u, nrows, ncols);
    pc          = rbcluster_rows2rb(v, ndata, ndata);
  } else {
    pc          = rbcluster_rows2rb(u, nrows, ncols);
    coordinates = rbcluster_rows2rb(v, ndata, ndata);
  }

  rbcluster_free_rows(u, nrows);
  rbcluster_free_rows(v, ndata);

  free(w);
  free(means);

  return rb_ary_new3(4, mean, coordinates, pc, eigenvalues);
}

VALUE rbcluster_cuttree(VALUE self, VALUE nodes, VALUE clusters) {
  int nelements, nclusters;

  nclusters = NUM2INT(clusters);

  Node* cnodes = rbcluster_ary_to_nodes(nodes, &nelements);
  int n = nelements + 1;

  if(nclusters < 1) {
    rb_raise(rb_eArgError, "nclusters must be >= 1");
  }

  if(nclusters > n) {
    rb_raise(rb_eArgError, "more clusters requested than items available");
  }

  int clusterid[n];
  cuttree(n, cnodes, nclusters, clusterid);
  free(cnodes);

  if(clusterid[0] == -1) {
    rb_raise(rb_eNoMemError, "could not allocate memory for cuttree()");
  }

  return rbcluster_ints2rb(clusterid, (long)n);
}

void Init_rbcluster() {
  rbcluster_mCluster = rb_define_module("Cluster");
  rbcluster_cNode = rb_define_class_under(rbcluster_mCluster, "Node", rb_cObject);
  rbcluster_cTree = rb_define_class_under(rbcluster_mCluster, "Tree", rb_cObject);

  rb_define_attr(rbcluster_cNode, "left", 1, 1);
  rb_define_attr(rbcluster_cNode, "right", 1, 1);
  rb_define_attr(rbcluster_cNode, "distance", 1, 1);
  rb_define_method(rbcluster_cNode, "initialize", rbcluster_node_initialize, -1);

  rb_define_singleton_method(rbcluster_mCluster, "median", rbcluster_median, 1);
  rb_define_singleton_method(rbcluster_mCluster, "mean", rbcluster_mean, 1);

  rb_define_singleton_method(rbcluster_mCluster, "kcluster", rbcluster_kcluster, -1);
  rb_define_singleton_method(rbcluster_mCluster, "distancematrix", rbcluster_distancematrix, -1);
  rb_define_singleton_method(rbcluster_mCluster, "kmedoids", rbcluster_kmedoids, -1);
  rb_define_singleton_method(rbcluster_mCluster, "clusterdistance", rbcluster_clusterdistance, -1);
  rb_define_singleton_method(rbcluster_mCluster, "treecluster", rbcluster_treecluster, -1);
  rb_define_singleton_method(rbcluster_mCluster, "somcluster", rbcluster_somcluster, -1);
  rb_define_singleton_method(rbcluster_mCluster, "pca", rbcluster_pca, 1);
  rb_define_singleton_method(rbcluster_mCluster, "cuttree", rbcluster_cuttree, 2);

  rb_define_const(rbcluster_mCluster, "C_VERSION", rb_str_new2(CLUSTERVERSION));
}
