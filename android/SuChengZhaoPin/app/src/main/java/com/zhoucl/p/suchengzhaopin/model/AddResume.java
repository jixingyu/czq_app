package com.zhoucl.p.suchengzhaopin.model;

/**
 * Created by zhoucl on 2015/7/20.
 */
public class AddResume {
    public int code;
    public String error;
    public Data data;

    public static class Data {
        public int id;
        public String resume_name;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getResume_name() {
            return resume_name;
        }

        public void setResume_name(String resume_name) {
            this.resume_name = resume_name;
        }
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
