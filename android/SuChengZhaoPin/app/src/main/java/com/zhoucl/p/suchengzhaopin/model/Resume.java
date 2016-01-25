package com.zhoucl.p.suchengzhaopin.model;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/20.
 */
public class Resume {
    public int code;
    public String error;
    public List<Data> data;
    public Pagination pagination;

    public static class Data {
        public String id;
        public String resume_name;

        public String getResume_name() {
            return resume_name;
        }

        public void setResume_name(String resume_name) {
            this.resume_name = resume_name;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }
    }

    public static class Pagination {
        public int page;
        public int pageSize;
        public int total;

        public int getPage() {
            return page;
        }

        public void setPage(int page) {
            this.page = page;
        }

        public int getPageSize() {
            return pageSize;
        }

        public void setPageSize(int pageSize) {
            this.pageSize = pageSize;
        }

        public int getTotal() {
            return total;
        }

        public void setTotal(int total) {
            this.total = total;
        }
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public List<Data> getData() {
        return data;
    }

    public void setData(List<Data> data) {
        this.data = data;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public Pagination getPagination() {
        return pagination;
    }

    public void setPagination(Pagination pagination) {
        this.pagination = pagination;
    }
}
