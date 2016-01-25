package com.zhoucl.p.suchengzhaopin.model;

import android.text.format.DateFormat;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/20.
 */
public class Invite {
    public int code;
    public String error;
    public List<Data> data;
    public Pagination pagination;

    public static class Data {
        public String address;
        public String job_id;
        public String interview_time;
        public String company;
        public String job;

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getCompany() {
            return company;
        }

        public void setCompany(String company) {
            this.company = company;
        }

        public String getInterview_time() {
            return DateFormat.format("yyyy-MM-dd kk:mm", Long.parseLong(interview_time) * 1000L).toString();
        }

        public void setInterview_time(String interview_time) {
            this.interview_time = interview_time;
        }

        public String getJob() {
            return job;
        }

        public void setJob(String job) {
            this.job = job;
        }

        public String getJob_id() {
            return job_id;
        }

        public void setJob_id(String job_id) {
            this.job_id = job_id;
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
