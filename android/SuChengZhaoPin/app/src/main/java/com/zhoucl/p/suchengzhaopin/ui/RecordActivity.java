package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewStub;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.melnykov.fab.FloatingActionButton;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.adapter.RecordAdapter;
import com.zhoucl.p.suchengzhaopin.model.Job;
import com.zhoucl.p.suchengzhaopin.util.DividerItemDecoration;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by zhoucl on 2015/7/31.
 */
public class RecordActivity extends BaseActivity implements View.OnClickListener,
        SwipeRefreshLayout.OnRefreshListener, RecordAdapter.OnItemClickListener {

    private static String URL_APPLY_LIST = IP + "/app/api/apply_list";//GET

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.swipe_refresh_layout)
    private SwipeRefreshLayout swipeRefreshLayout;

    @ViewInject(R.id.record_list)
    private RecyclerView recordList;

    @ViewInject(R.id.more_record_fab)
    private FloatingActionButton moreFab;

    @ViewInject(R.id.record_top_text)
    private TextView topText;

    private LinearLayoutManager layoutManager;
    private RecordAdapter adapter;
    private List<Job.Data> data = new ArrayList<Job.Data>();

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;
    private Job jobs;
    private int page = 1;
    private int pageSize;
    private int total;

    private View nullView;

    private boolean refreshFlag = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_send_record);
        ViewUtils.inject(this);

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(1000);
        init();
    }

    public void init () {
        titleText.setText(R.string.send_record);

        moreFab.attachToRecyclerView(recordList);

        swipeRefreshLayout.setOnRefreshListener(this);
        layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        recordList.setLayoutManager(layoutManager);
        recordList.setHasFixedSize(true);
        recordList.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL_LIST));
        adapter = new RecordAdapter(data, this);
        recordList.setAdapter(adapter);

        adapter.setOnItemClickListener(this);
        recordList.addOnScrollListener(scrollListener);

        moreFab.setOnClickListener(this);
        backBtn.setOnClickListener(this);

        getRecord(page, false, false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (refreshFlag) {
            page = 1;
            getRecord(page, false, true);
            refreshFlag = false;
        }
    }

    private void showNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.VISIBLE);
            return;
        }

        ViewStub stub = (ViewStub) findViewById(R.id.record_null_lay);
        nullView = stub.inflate();
        ImageView nullImg = (ImageView) nullView.findViewById(R.id.null_img);
        nullImg.setImageResource(R.drawable.img_record_null);
    }

    private void cancelNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        if (v.equals(backBtn)) {
            finish();
        } else if (v.equals(moreFab)) {
            if (data.size() < total) {
                page++;
                getRecord(page, true, false);
            } else {
                Toast.makeText(RecordActivity.this, R.string.no_more, Toast.LENGTH_SHORT).show();
            }
        }
    }

    public RecyclerView.OnScrollListener scrollListener = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            if (layoutManager.findLastVisibleItemPosition() == (data.size() - 1)) {
                moreFab.show();
            }
        }
    };

    @Override
    public void onRefresh() {
        page = 1;
        getRecord(page, false, true);
    }

    @Override
    public void onItemClick(View view, int position) {
        refreshFlag = true;
        Intent intent = new Intent(RecordActivity.this, JobDetailsActivity.class);
        intent.putExtra("job_id", data.get(position).getJob_id());
        startActivity(intent);
    }

    private void getRecord(int mPage, final boolean isAddMore, final boolean isPullToRefresh) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("page", mPage);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_APPLY_LIST, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getRecord : " + responseInfo.result.toString());
                        if (!isAddMore) {
                            data.clear();
                        }

                        Type type = new TypeToken<Job>() {
                        }.getType();
                        jobs = gson.fromJson(responseInfo.result.toString(), type);
                        if (jobs.getCode() == 1) {
                            data.addAll(jobs.getData());
                            page = jobs.getPagination().getPage();
                            pageSize = jobs.getPagination().getPageSize();
                            total = jobs.getPagination().getTotal();

                            topText.setText(String.format(getResources().getString(R.string.record_top_text), total));

                            adapter.notifyDataSetChanged();
                            if (isAddMore) {
                                recordList.scrollToPosition((page - 1) * pageSize);
                            }

                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }

                            if (data.size() < total) {
                                moreFab.setVisibility(View.VISIBLE);
                            } else {
                                moreFab.setVisibility(View.INVISIBLE);
                            }

                        } else {
                            if (checkLoginState(jobs.getCode(), RecordActivity.this)) {
                                Toast.makeText(RecordActivity.this, jobs.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                        if (isPullToRefresh) {
                            swipeRefreshLayout.setRefreshing(false);
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(RecordActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }
}
