package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;

import com.zhoucl.p.suchengzhaopin.model.Province;
import com.zhoucl.wheel.adapters.AbstractWheelTextAdapter;

import java.util.List;

/**
 * Created by zhoucl on 2015/7/28.
 */
public class ProvinceAdapter extends AbstractWheelTextAdapter {

    private List<Province> listData;

    public ProvinceAdapter(Context context, List<Province> listData) {
        super(context);
        this.listData = listData;
    }

    @Override
    protected CharSequence getItemText(int index) {
        return listData.get(index).getProvince();
    }

    @Override
    public int getItemsCount() {
        return listData.size();
    }
}
