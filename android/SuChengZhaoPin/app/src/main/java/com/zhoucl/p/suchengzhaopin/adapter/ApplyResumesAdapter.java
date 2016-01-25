package com.zhoucl.p.suchengzhaopin.adapter;

import android.content.Context;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.Toast;

import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.Resume;
import com.zhoucl.p.suchengzhaopin.ui.JobDetailsActivity;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.util.HashMap;
import java.util.List;

public class ApplyResumesAdapter extends BaseAdapter {
    private List<Resume.Data> data;
    private Context mContext;
    private String URL_APPLY;//POST job_id resume_id
    private String job_id;
    private Handler handler;

    public ApplyResumesAdapter(List<Resume.Data> data, Context mContext, String url, String job_id, Handler handler) {
        super();
        this.data = data;
        this.mContext = mContext;
        this.URL_APPLY = url;
        this.job_id = job_id;
        this.handler = handler;
    }

    @Override
    public int getCount() {
        if (data == null) {
            return 0;
        } else {
            return this.data.size();
        }
    }

    @Override
    public Object getItem(int position) {
        if (data == null) {
            return null;
        } else {
            return this.data.get(position);
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
            convertView = LayoutInflater.from(this.mContext).inflate(R.layout.item_apply_resume, null, false);
            holder.resume_item_btn = (Button) convertView.findViewById(R.id.resume_item_btn);

            holder.resume_item_btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    doApply(job_id, data.get(position).getId());
                }
            });

            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (this.data != null) {
            if (holder.resume_item_btn != null) {
                holder.resume_item_btn.setText(data.get(position).getResume_name());
            }
        }
        return convertView;
    }

    private class ViewHolder {
        Button resume_item_btn;
    }

    private void doApply(String job_id, String resume_id) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("job_id", job_id);
        params.addBodyParameter("resume_id", resume_id);
        HttpUtilsWithToken httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_APPLY,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("doApply : " + responseInfo.result.toString());
                        HashMap<String, Object> map = ((JobDetailsActivity)mContext).parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            if (((JobDetailsActivity)mContext).checkLoginState((int) map.get("code"), mContext)) {
                                Toast.makeText(mContext, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            handler.sendEmptyMessage(0);
                            Toast.makeText(mContext, R.string.apply_successful, Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(mContext, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
