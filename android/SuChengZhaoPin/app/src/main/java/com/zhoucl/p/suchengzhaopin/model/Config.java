package com.zhoucl.p.suchengzhaopin.model;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/9.
 */
public class Config {
    public int code;
    public String error;
    public Data data;

    public static class Data {
        public List<String> degree;
        public List<String> district;
        public List<String> political_status;
        public int resume_limit;
        public int force_update;//1:强制更新

        public List<String> getDegree() {
            return degree;
        }

        public void setDegree(List<String> degree) {
            this.degree = degree;
        }

        public List<String> getDistrict() {
            return district;
        }

        public void setDistrict(List<String> district) {
            this.district = district;
        }

        public List<String> getPolitical_status() {
            return political_status;
        }

        public void setPolitical_status(List<String> political_status) {
            this.political_status = political_status;
        }

        public int getResume_limit() {
            return resume_limit;
        }

        public void setResume_limit(int resume_limit) {
            this.resume_limit = resume_limit;
        }

        public int getForce_update() {
            return force_update;
        }

        public void setForce_update(int force_update) {
            this.force_update = force_update;
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
