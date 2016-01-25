package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.Adapter;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;

import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.Job;
import com.zhoucl.p.suchengzhaopin.ui.BaseActivity;
import com.zhoucl.p.suchengzhaopin.ui.RecordActivity;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.util.HashMap;
import java.util.List;

/**
 * @author zhoucl
 */
public class RecordAdapter extends Adapter<RecordAdapter.ViewHolder> {
    private static String URL_FAVORITE = BaseActivity.IP + "/app/api/favorite";//POST job_id
    private Context context;
    private List<Job.Data> data;
//    private String salaryUnit;
    OnItemClickListener mItemClickListener;
    OnItemLongClickListener mItemLongClickListener;

    /**
     * @Description: TODO
     */
    public RecordAdapter(List<Job.Data> data, Context context) {
        this.context = context;
        this.data = data;
//        salaryUnit = context.getResources().getString(R.string.salary_unit);
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.item_job_user_center, null);
        ViewHolder holder = new ViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.job_name.setText(data.get(position).getJob());
        holder.update_time.setText(data.get(position).getDate());
        holder.company_name.setText(data.get(position).getCompany());
        holder.degree_limit.setText(data.get(position).getDegree());
        holder.salary.setText(data.get(position).getSalary());
        if (data.get(position).getIs_favorite() == 1) {
            holder.favorite_btn.setChecked(true);
        } else {
            holder.favorite_btn.setChecked(false);
        }
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements OnClickListener, OnLongClickListener {
        public TextView job_name, update_time, company_name, salary, degree_limit;
        public CheckBox favorite_btn;

        public ViewHolder(View itemView) {
            super(itemView);
            job_name = (TextView) itemView.findViewById(R.id.job_name);
            update_time = (TextView) itemView.findViewById(R.id.update_time);
            company_name = (TextView) itemView.findViewById(R.id.company_name);
            salary = (TextView) itemView.findViewById(R.id.salary);
            degree_limit = (TextView) itemView.findViewById(R.id.degree_limit);
            favorite_btn = (CheckBox) itemView.findViewById(R.id.favorite_btn);
            itemView.setOnClickListener(this);
            itemView.setOnLongClickListener(this);
            favorite_btn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    doFavorite(data.get(getLayoutPosition()).getJob_id(), v);
                }
            });
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

    private void doFavorite(String job_id, final View v) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("job_id", job_id);
        HttpUtilsWithToken httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_FAVORITE,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("doFavorite : " + responseInfo.result.toString());
                        HashMap<String, Object> map = ((RecordActivity) context).parseSimpleJson(responseInfo.result.toString());

                        if ((int) map.get("code") != 1) {
                            ((CheckBox) v).setChecked(!((CheckBox) v).isChecked());
                            if (((RecordActivity) context).checkLoginState((int) map.get("code"), context)) {
                                Toast.makeText(context, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            if (((CheckBox) v).isChecked()) {
                                Toast.makeText(context, R.string.do_favorite_successful, Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(context, R.string.cancel_favorite_successful, Toast.LENGTH_SHORT).show();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(context, s, Toast.LENGTH_SHORT).show();
                    }
                });
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