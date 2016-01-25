package com.zhoucl.p.suchengzhaopin.model;

import android.text.format.DateFormat;

/**
 * Created by zhoucl on 2015/7/16.
 */
public class Details {
    public int code;
    public String error;
    public Data data;

    public static class Data {
        public String id;
        public String name;
        public String degree;
        public String salary;
        public String district;
        public String company_id;
        public String working_years;
        public String recruit_number;
        public String job_type;
        public String benefit;
        public String requirement;
        public String is_deleted;
        public String create_time;
        public String update_time;
        public String c_name;
        public String c_description;
        public String c_address;
        public String c_industry;
        public String c_number;
        public int applied;
        public int is_favorite;

        public String getBenefit() {
            return benefit;
        }

        public void setBenefit(String benefit) {
            this.benefit = benefit;
        }

        public String getC_address() {
            return c_address;
        }

        public void setC_address(String c_address) {
            this.c_address = c_address;
        }

        public String getC_description() {
            return c_description;
        }

        public void setC_description(String c_description) {
            this.c_description = c_description;
        }

        public String getC_industry() {
            return c_industry;
        }

        public void setC_industry(String c_industry) {
            this.c_industry = c_industry;
        }

        public String getC_name() {
            return c_name;
        }

        public void setC_name(String c_name) {
            this.c_name = c_name;
        }

        public String getC_number() {
            return c_number;
        }

        public void setC_number(String c_number) {
            this.c_number = c_number;
        }

        public String getCompany_id() {
            return company_id;
        }

        public void setCompany_id(String company_id) {
            this.company_id = company_id;
        }

        public String getCreate_time() {
            return create_time;
        }

        public void setCreate_time(String create_time) {
            this.create_time = create_time;
        }

        public String getDegree() {
            return degree;
        }

        public void setDegree(String degree) {
            this.degree = degree;
        }

        public String getDistrict() {
            return district;
        }

        public void setDistrict(String district) {
            this.district = district;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getIs_deleted() {
            return is_deleted;
        }

        public void setIs_deleted(String is_deleted) {
            this.is_deleted = is_deleted;
        }

        public String getJob_type() {
            return job_type;
        }

        public void setJob_type(String job_type) {
            this.job_type = job_type;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getRecruit_number() {
            return recruit_number;
        }

        public void setRecruit_number(String recruit_number) {
            this.recruit_number = recruit_number;
        }

        public String getRequirement() {
            return requirement;
        }

        public void setRequirement(String requirement) {
            this.requirement = requirement;
        }

        public String getSalary() {
            return salary;
        }

        public void setSalary(String salary) {
            this.salary = salary;
        }

        public String getUpdate_time() {
            return DateFormat.format("MM-dd", Long.parseLong(update_time + "000")).toString();
        }

        public void setUpdate_time(String update_time) {
            this.update_time = update_time;
        }

        public String getWorking_years() {
            return working_years;
        }

        public void setWorking_years(String working_years) {
            this.working_years = working_years;
        }

        public int getApplied() {
            return applied;
        }

        public void setApplied(int applied) {
            this.applied = applied;
        }

        public int getIs_favorite() {
            return is_favorite;
        }

        public void setIs_favorite(int is_favorite) {
            this.is_favorite = is_favorite;
        }
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }
}
