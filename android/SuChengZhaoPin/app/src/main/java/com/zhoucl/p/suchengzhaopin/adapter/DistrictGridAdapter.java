package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.ui.SearchFragment;

import java.util.List;

public class DistrictGridAdapter extends BaseAdapter {
    private List<String> infoList;
    private Context mContext;

    public DistrictGridAdapter(List<String> infoList, Context mContext) {
        super();
        this.infoList = infoList;
        this.mContext = mContext;
    }

    @Override
    public int getCount() {
        if (infoList == null) {
            return 0;
        } else {
            return this.infoList.size();
        }
    }

    @Override
    public Object getItem(int position) {
        if (infoList == null) {
            return null;
        } else {
            return this.infoList.get(position);
        }
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {
            holder = new ViewHolder();
            convertView = LayoutInflater.from(this.mContext).inflate(R.layout.item_district, null, false);
            holder.areaItemText = (TextView) convertView.findViewById(R.id.areaItemText);

            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (this.infoList != null) {
            if (holder.areaItemText != null) {
                holder.areaItemText.setText(infoList.get(position));
                if (SearchFragment.districtClickPosition != position) {
                    holder.areaItemText.setBackgroundResource(R.drawable.selector_area);
                } else {
                    holder.areaItemText.setBackgroundResource(R.drawable.bg_area_selected);
                }
            }
        }
        return convertView;
    }

    private class ViewHolder {
        TextView areaItemText;
    }
}
