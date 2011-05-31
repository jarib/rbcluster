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

double** rbcluster_fetch_data(VALUE data, int* nrows, int* ncols) {
  Check_Type(data, T_ARRAY);
  
  *nrows = RARRAY_LEN(data);
  VALUE first_element = rb_ary_entry(data, 0);
  Check_Type(first_element, T_ARRAY);
  *ncols = RARRAY_LEN(first_element);
  
  double** result = malloc((*nrows)*sizeof(double*));
  
  int i, n;
  VALUE row;
  
  for(i = 0; i < *nrows; ++i) {
    result[i] = malloc((*ncols)*sizeof(double));
    row = rb_ary_entry(data, i);
    Check_Type(row, T_ARRAY);
    assert(RARRAY_LEN(row) == *ncols);
    for(n = 0; n < *ncols; ++n) {
      result[i][n] = NUM2DBL(rb_ary_entry(row, n));
    }
  }
  
  return result;
}

void rbcluster_free_data(double** data, int nrows) {
  int i;
  for(i = 0; i < nrows; ++i) {
    free(data[i]);
  }
  
  free(data);
}

VALUE rbcluster_int_ary2rb(int* ints, long rows) {
  VALUE ary = rb_ary_new2(rows);
  int i;
  for(i = 0; i < rows; ++i) {
    rb_ary_push(ary, INT2FIX(ints[i]));
  }
  
  return ary;
}

VALUE rbcluster_kcluster(VALUE self, VALUE arr, VALUE opts) {

  
  int nrows, ncols; 
  double** data = rbcluster_fetch_data(arr, &nrows, &ncols);
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
  const char dist = 'e';
  const char method = 'a';
  
  double* weight = malloc(ncols*sizeof(double));
  int* clusterid = malloc(nrows*sizeof(int));
  double** cdata = malloc(nclusters*sizeof(double*));
  int** cmask    = malloc(nclusters*sizeof(int*));
  
  for(i = 0; i < nclusters; ++i)
  {
    cdata[i] = malloc(ncols*sizeof(double));
    cmask[i] = malloc(ncols*sizeof(int));
  }
  
  for (i = 0; i < ncols; i++) 
    weight[i] = 1.0;
  
  if(opts != Qnil) {
    Check_Type(opts, T_HASH);
    VALUE val; 
    
    val = rb_hash_aref(opts, ID2SYM(rb_intern("clusters")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_FIXNUM);
      nclusters = FIX2INT(val);
    }
    
    // TODO: mask
    // TODO: weigth
    // TODO: transpose
    
    val = rb_hash_aref(opts, ID2SYM(rb_intern("passes")));
    if(TYPE(val) != Qnil) {
      Check_Type(val, T_FIXNUM);
      npass = FIX2INT(val);
    }
    
    // TODO: method
    // TODO: distance
  }
  // Check_Type(nclusters, T_FIXNUM);
  // Check_Type(nrows, T_FIXNUM);
  // Check_Type(ncolumns, T_FIXNUM);
  
  kcluster(nclusters, nrows, ncols, data, mask, weight, transpose, npass, method, dist, clusterid, &error, &ifound);

  VALUE result = rbcluster_int_ary2rb(clusterid, nrows);
  // getclustercentroids(nclusters, nrows, ncols, data, mask, clusterid, cdata, cmask, transpose, method);
  // VALUE result = rbcluster_data2rb(cdata, nclusters, ncols);
  
  rbcluster_free_data(data, nrows);
  
  free(weight);
  // for(i = 0; i < nclusters; ++i) {
  //   free(cdata[i]);
  //   free(cmask[i]);
  // }
  free(clusterid);
  for(i = 0; i < nrows; ++i) {
    free(mask[i]);
  }
  free(mask);
  
  return result;
}

void Init_rbcluster() {
  Cluster = rb_define_module("Cluster");
  rb_define_singleton_method(Cluster, "kcluster", rbcluster_kcluster, 2);
}