package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewStub;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.melnykov.fab.FloatingActionButton;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.adapter.ResumesAdapter;
import com.zhoucl.p.suchengzhaopin.model.AddResume;
import com.zhoucl.p.suchengzhaopin.model.Resume;
import com.zhoucl.p.suchengzhaopin.util.DividerItemDecoration;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by zhoucl on 2015/7/20.
 */
public class MyResumeActivity extends BaseActivity implements View.OnClickListener,
        SwipeRefreshLayout.OnRefreshListener,
        ResumesAdapter.OnItemClickListener,
        ResumesAdapter.OnItemLongClickListener {

    private static String URL_RESUME_LIST = IP + "/app/resume_api/resume_list";//GET page
    private static String URL_ADD_RESUME = IP + "/app/resume_api/add_resume";//GET
    private static String URL_DELETE_RESUME = IP + "/app/resume_api/resume";//DELETE resume_id

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.swipe_refresh_layout)
    private SwipeRefreshLayout swipeRefreshLayout;

    @ViewInject(R.id.resume_list)
    private RecyclerView resumeList;

    @ViewInject(R.id.create_resume_btn)
    private Button createResumeBtn;

    @ViewInject(R.id.more_resumes_fab)
    private FloatingActionButton moreResumesFab;

    private LinearLayoutManager layoutManager;
    private ResumesAdapter resumeAdapter;
    private List<Resume.Data> data = new ArrayList<>();

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;
    private Resume resumes;
    private AddResume addResume;

    private int page = 1;
    private int pageSize;
    private int total;

    private View nullView;

    private MaterialDialog deleteDialog;
    private int deletePosition;

    private boolean refreshFlag = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_my_resume);
        ViewUtils.inject(this);

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(1000);
        init();
    }

    public void init() {
        titleText.setText(R.string.my_resume);

        moreResumesFab.attachToRecyclerView(resumeList);
        swipeRefreshLayout.setOnRefreshListener(this);
        layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        resumeList.setLayoutManager(layoutManager);
        resumeList.setHasFixedSize(true);
        resumeList.addItemDecoration(new DividerItemDecoration(MyResumeActivity.this, DividerItemDecoration.VERTICAL_LIST));
        resumeAdapter = new ResumesAdapter(data, this);
        resumeList.setAdapter(resumeAdapter);

        resumeAdapter.setOnItemClickListener(this);
        resumeAdapter.setOnItemLongClickListener(this);
        resumeList.addOnScrollListener(scrollListener);

        titleBackBtn.setOnClickListener(this);
        createResumeBtn.setOnClickListener(this);
        moreResumesFab.setOnClickListener(this);

        getResumeList(page, false, false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (refreshFlag) {
            page = 1;
            getResumeList(page, false, true);
            refreshFlag = false;
        }
    }

    private void showNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.VISIBLE);
            return;
        }

        ViewStub stub = (ViewStub) findViewById(R.id.resume_null_lay);
        nullView = stub.inflate();
        ImageView nullImg = (ImageView) nullView.findViewById(R.id.null_img);
        nullImg.setImageResource(R.drawable.img_resume_null);
    }

    private void cancelNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.GONE);
        }
    }

    private void initDeleteDialog () {
        deleteDialog = new MaterialDialog.Builder(this)
                .items(new String[]{getResources().getString(R.string.delete)})
                .itemsCallback(new MaterialDialog.ListCallback() {
                    @Override
                    public void onSelection(MaterialDialog dialog, View view, int which, CharSequence text) {
                        delResume(data.get(deletePosition).getId());
                    }
                })
                .build();
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            finish();
        } else if (v.equals(createResumeBtn)) {
            addResume();
        } else if (v.equals(moreResumesFab)) {
            if (data.size() < total) {
                page++;
                getResumeList(page, true, false);
            } else {
                Toast.makeText(MyResumeActivity.this, R.string.no_more, Toast.LENGTH_SHORT).show();
            }
        }
    }

    @Override
    public void onItemClick(View view, int position) {
        Intent intent = new Intent(MyResumeActivity.this, EditResumeActivity.class);
        intent.putExtra("resume_id", data.get(position).getId());
        startActivity(intent);
        refreshFlag = true;
    }

    @Override
    public void onItemLongClick(View view, int position) {
        deletePosition = position;
        if (deleteDialog == null) {
            initDeleteDialog();
        }
        deleteDialog.show();
    }

    public RecyclerView.OnScrollListener scrollListener = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            if (layoutManager.findLastVisibleItemPosition() == (data.size() - 1)) {
                moreResumesFab.show();
            }
        }
    };

    @Override
    public void onRefresh() {
        page = 1;
        getResumeList(page, false, true);
    }

    private void getResumeList(int mPage, final boolean isAddMore, final boolean isPullToRefresh) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("page", mPage);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_RESUME_LIST, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getResumeList : " + responseInfo.result.toString());
                        if (!isAddMore) {
                            data.clear();
                        }

                        Type type = new TypeToken<Resume>() {
                        }.getType();
                        resumes = gson.fromJson(responseInfo.result.toString(), type);
                        if (resumes.getCode() == 1) {
                            data.addAll(resumes.getData());
                            page = resumes.getPagination().getPage();
                            pageSize = resumes.getPagination().getPageSize();
                            total = resumes.getPagination().getTotal();

                            resumeAdapter.notifyDataSetChanged();
                            if (isAddMore) {
                                resumeList.scrollToPosition((page - 1) * pageSize);
                            }

                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }

                            if (data.size() < RESUME_LIMIT) {
                                createResumeBtn.setVisibility(View.VISIBLE);
                                if (data.size() < total) {
                                    moreResumesFab.setVisibility(View.VISIBLE);
                                }
                            } else {
                                createResumeBtn.setVisibility(View.GONE);
                            }
                        } else {
                            if (checkLoginState(resumes.getCode(), MyResumeActivity.this)) {
                                Toast.makeText(MyResumeActivity.this, resumes.getError(), Toast.LENGTH_SHORT).show();
                            } else {
                                refreshFlag = true;
                            }
                        }

                        cancelProgressDialog();
                        if (isPullToRefresh) {
                            swipeRefreshLayout.setRefreshing(false);
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(MyResumeActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    private void addResume() {
        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                URL_ADD_RESUME,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("addResume : " + responseInfo.result.toString());
                        Type type = new TypeToken<AddResume>() {
                        }.getType();
                        addResume = gson.fromJson(responseInfo.result.toString(), type);
                        if (addResume.getCode() == 1) {
                            //跳转到编辑简历页
                            Intent intent = new Intent(MyResumeActivity.this, EditResumeActivity.class);
                            intent.putExtra("resume_id", String.valueOf(addResume.getData().getId()));
                            startActivity(intent);
                            refreshFlag = true;
                        } else {
                            if (checkLoginState(addResume.getCode(), MyResumeActivity.this)) {
                                Toast.makeText(MyResumeActivity.this, addResume.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(MyResumeActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    private void delResume(String resume_id) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("resume_id", resume_id);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.DELETE,
                URL_DELETE_RESUME,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("delResume : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            if (checkLoginState((int)map.get("code"), MyResumeActivity.this)) {
                                Toast.makeText(MyResumeActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            Toast.makeText(MyResumeActivity.this, R.string.delete_complete, Toast.LENGTH_SHORT).show();
//                            data.remove(deletePosition);
//                            resumeAdapter.notifyItemRemoved(deletePosition);
                            page = 1;
                            getResumeList(page, false, true);
                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(MyResumeActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
