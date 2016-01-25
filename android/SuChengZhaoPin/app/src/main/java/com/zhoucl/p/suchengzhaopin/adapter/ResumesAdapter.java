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
import com.zhoucl.p.suchengzhaopin.model.Resume;

import java.util.List;

/**
 * @author zhoucl
 */
public class ResumesAdapter extends Adapter<ResumesAdapter.ViewHolder> {
    private Context context;
    private List<Resume.Data> data;
    OnItemClickListener mItemClickListener;
    OnItemLongClickListener mItemLongClickListener;

    /**
     * @Description: TODO
     */
    public ResumesAdapter(List<Resume.Data> data, Context context) {
        this.context = context;
        this.data = data;
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.item_resume, null);
        ViewHolder holder = new ViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.resume_count_text.setText(String.valueOf(position + 1));
        holder.resume_name_text.setText(data.get(position).getResume_name());
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements OnClickListener, OnLongClickListener {
        public TextView resume_count_text, resume_name_text;

        public ViewHolder(View itemView) {
            super(itemView);
            resume_count_text = (TextView) itemView.findViewById(R.id.resume_count_text);
            resume_name_text = (TextView) itemView.findViewById(R.id.resume_name_text);
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