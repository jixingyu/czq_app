package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;

import com.zhoucl.p.suchengzhaopin.model.City;
import com.zhoucl.wheel.adapters.AbstractWheelTextAdapter;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/28.
 */
public class CityAdapter extends AbstractWheelTextAdapter {

    private List<City> listData;

    public CityAdapter(Context context, List<City> listData) {
        super(context);
        this.listData = listData;
    }

    @Override
    protected CharSequence getItemText(int index) {
        return listData.get(index).getName();
    }

    @Override
    public int getItemsCount() {
        return listData.size();
    }
}
