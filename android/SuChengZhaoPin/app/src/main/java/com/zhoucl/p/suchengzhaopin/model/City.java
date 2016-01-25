package com.zhoucl.p.suchengzhaopin.model;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/28.
 */
public class City {
    private String name;
    private List<Area> area;

    public List<Area> getArea() {
        return area;
    }

    public void setArea(List<Area> area) {
        this.area = area;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
