package com.zhoucl.p.suchengzhaopin.model;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/28.
 */
public class Province {
    private String province;
    private List<City> city;

    public List<City> getCity() {
        return city;
    }

    public void setCity(List<City> city) {
        this.city = city;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }
}
