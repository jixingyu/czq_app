package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.Adapter;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.widget.TextView;

import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.Experience;

import java.text.SimpleDateFormat;
import java.util.List;

/**
 * @author zhoucl
 */
public class ExperienceAdapter extends Adapter<ExperienceAdapter.ViewHolder> {
    private Context context;
    private List<Experience.Data> data;
    private SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy.MM");
    private long startTime, endTime;
    private String tillNow;
    OnItemClickListener mItemClickListener;
    OnItemLongClickListener mItemLongClickListener;

    /**
     * @Description: TODO
     */
    public ExperienceAdapter(List<Experience.Data> data, Context context) {
        this.context = context;
        this.data = data;
        tillNow = context.getResources().getString(R.string.till_now);
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.item_experience, null);
        ViewHolder holder = new ViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.experience_name_text.setText(data.get(position).getCompany());
        startTime = Long.parseLong(data.get(position).getStart_time()) * 1000L;
        endTime = Long.parseLong(data.get(position).getEnd_time()) * 1000L;
        if (startTime != 0 && endTime != 0) {
            if (endTime < 0) {
                holder.experience_time_text.setText(simpleDateFormat.format(startTime) + "-" + tillNow);
            } else {
                holder.experience_time_text.setText(simpleDateFormat.format(startTime) + "-" + simpleDateFormat.format(endTime));
            }
        }
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements OnClickListener, OnLongClickListener {
        public TextView experience_name_text, experience_time_text;

        public ViewHolder(View itemView) {
            super(itemView);
            experience_name_text = (TextView) itemView.findViewById(R.id.experience_name_text);
            experience_time_text = (TextView) itemView.findViewById(R.id.experience_time_text);
            itemView.setOnClickListener(this);
            itemView.setOnLongClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (mItemClickListener != null) {
                mItemClickListener.onItemClick(v, getLayoutPosition());
            }
        }

        @Override
        public boolean onLongClick(View v) {
            if (mItemLongClickListener != null) {
                mItemLongClickListener.onItemLongClick(v, getLayoutPosition());
            }
            return false;
        }
    }

    /**
     * ItemClick的回调接口
     */
    public interface OnItemClickListener {
        public void onItemClick(View view, int position);
    }

    /**
     * ItemClick设置回调监听
     *
     * @param mItemClickListener
     */
    public void setOnItemClickListener(final OnItemClickListener mItemClickListener) {
        this.mItemClickListener = mItemClickListener;
    }

    /**
     * ItemLongClick的回调接口
     */
    public interface OnItemLongClickListener {
        public void onItemLongClick(View view, int position);
    }

    /**
     * ItemLongClick设置回调监听
     *
     * @param mItemLongClickListener
     */
    public void setOnItemLongClickListener(final OnItemLongClickListener mItemLongClickListener) {
        this.mItemLongClickListener = mItemLongClickListener;
    }
}