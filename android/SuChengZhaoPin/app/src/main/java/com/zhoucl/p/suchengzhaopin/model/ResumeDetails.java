package com.zhoucl.p.suchengzhaopin.model;

/**
 * Created by zhoucl on 2015/7/21.
 */
public class ResumeDetails {
    public int code;
    public String error;
    public Data data;

    public static class Data {
        public String resume_name;
        public String real_name;
        public String gender;
        public String birthday;
        public String native_place;
        public String political_status;
        public String work_start_time;
        public String mobile;
        public String email;
        public String school;
        public String degree;
        public String major;
        public String evaluation;
        public String personal_info_completed;
        public String evaluation_completed;
        public String experience_completed;

        public String getDegree() {
            return degree;
        }

        public void setDegree(String degree) {
            this.degree = degree;
        }

        public String getBirthday() {
            return birthday;
        }

        public void setBirthday(String birthday) {
            this.birthday = birthday;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getEvaluation() {
            return evaluation;
        }

        public void setEvaluation(String evaluation) {
            this.evaluation = evaluation;
        }

        public String getEvaluation_completed() {
            return evaluation_completed;
        }

        public void setEvaluation_completed(String evaluation_completed) {
            this.evaluation_completed = evaluation_completed;
        }

        public String getExperience_completed() {
            return experience_completed;
        }

        public void setExperience_completed(String experience_completed) {
            this.experience_completed = experience_completed;
        }

        public String getGender() {
            return gender;
        }

        public void setGender(String gender) {
            this.gender = gender;
        }

        public String getMajor() {
            return major;
        }

        public void setMajor(String major) {
            this.major = major;
        }

        public String getMobile() {
            return mobile;
        }

        public void setMobile(String mobile) {
            this.mobile = mobile;
        }

        public String getNative_place() {
            return native_place;
        }

        public void setNative_place(String native_place) {
            this.native_place = native_place;
        }

        public String getPersonal_info_completed() {
            return personal_info_completed;
        }

        public void setPersonal_info_completed(String personal_info_completed) {
            this.personal_info_completed = personal_info_completed;
        }

        public String getPolitical_status() {
            return political_status;
        }

        public void setPolitical_status(String political_status) {
            this.political_status = political_status;
        }

        public String getReal_name() {
            return real_name;
        }

        public void setReal_name(String real_name) {
            this.real_name = real_name;
        }

        public String getResume_name() {
            return resume_name;
        }

        public void setResume_name(String resume_name) {
            this.resume_name = resume_name;
        }

        public String getSchool() {
            return school;
        }

        public void setSchool(String school) {
            this.school = school;
        }

        public String getWork_start_time() {
            return work_start_time;
        }

        public void setWork_start_time(String work_start_time) {
            this.work_start_time = work_start_time;
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
