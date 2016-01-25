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
import com.zhoucl.p.suchengzhaopin.model.Invite;

import java.util.List;

/**
 * @author zhoucl
 */
public class InviteAdapter extends Adapter<InviteAdapter.ViewHolder> {
    private Context context;
    private List<Invite.Data> data;
    OnItemClickListener mItemClickListener;
    OnItemLongClickListener mItemLongClickListener;

    /**
     * @Description: TODO
     */
    public InviteAdapter(List<Invite.Data> data, Context context) {
        this.context = context;
        this.data = data;
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.item_invite, null);
        ViewHolder holder = new ViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.company_name.setText(data.get(position).getCompany());
        holder.job_name.setText(data.get(position).getJob());
        holder.interview_time.setText(data.get(position).getInterview_time());
        holder.interview_place.setText(data.get(position).getAddress());
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements OnClickListener, OnLongClickListener {
        public TextView company_name, job_name, interview_time, interview_place;

        public ViewHolder(View itemView) {
            super(itemView);
            company_name = (TextView) itemView.findViewById(R.id.item_invite_company_name);
            job_name = (TextView) itemView.findViewById(R.id.item_invite_job_name);
            interview_time = (TextView) itemView.findViewById(R.id.item_invite_interview_time);
            interview_place = (TextView) itemView.findViewById(R.id.item_invite_interview_place);
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