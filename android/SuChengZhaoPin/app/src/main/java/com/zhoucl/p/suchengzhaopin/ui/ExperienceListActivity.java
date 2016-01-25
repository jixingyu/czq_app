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
import com.zhoucl.p.suchengzhaopin.adapter.ExperienceAdapter;
import com.zhoucl.p.suchengzhaopin.model.Experience;
import com.zhoucl.p.suchengzhaopin.util.DividerItemDecoration;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by zhoucl on 2015/7/29.
 */
public class ExperienceListActivity extends BaseActivity implements View.OnClickListener,
        SwipeRefreshLayout.OnRefreshListener,
        ExperienceAdapter.OnItemClickListener,
        ExperienceAdapter.OnItemLongClickListener {
    private static String URL_EXPERIENCE_LIST = IP + "/app/resume_api/experience_list";//GET resume_id page
    private static String URL_EXPERIENCE = IP + "/app/resume_api/experience";//DELETE experience_id

    private String resume_id;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.create_experience_btn)
    private Button createBtn;

    @ViewInject(R.id.swipe_refresh_layout)
    private SwipeRefreshLayout swipeRefreshLayout;

    @ViewInject(R.id.experience_list)
    private RecyclerView experienceList;

    @ViewInject(R.id.more_experience_fab)
    private FloatingActionButton moreFab;

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;
    private Experience experience;

    private LinearLayoutManager layoutManager;
    private ExperienceAdapter adapter;
    private List<Experience.Data> data = new ArrayList<>();

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
        setContentView(R.layout.layout_experience_list);
        ViewUtils.inject(this);

        Bundle bundle = getIntent().getExtras();
        resume_id = bundle.getString("resume_id");

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(1000);

        init();
    }

    public void init() {
        titleText.setText(R.string.work_experience);

        moreFab.attachToRecyclerView(experienceList);
        swipeRefreshLayout.setOnRefreshListener(this);
        layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        experienceList.setLayoutManager(layoutManager);
        experienceList.setHasFixedSize(true);
        experienceList.addItemDecoration(new DividerItemDecoration(ExperienceListActivity.this, DividerItemDecoration.VERTICAL_LIST));
        adapter = new ExperienceAdapter(data, this);
        experienceList.setAdapter(adapter);

        adapter.setOnItemClickListener(this);
        adapter.setOnItemLongClickListener(this);
        experienceList.addOnScrollListener(scrollListener);

        titleBackBtn.setOnClickListener(this);
        createBtn.setOnClickListener(this);
        moreFab.setOnClickListener(this);

        getExperienceList(page, false, false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (refreshFlag) {
            page = 1;
            getExperienceList(page, false, true);
            refreshFlag = false;
        }
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            finish();
        } else if (v.equals(createBtn)) {
            Intent intent = new Intent(ExperienceListActivity.this, EditExperienceActivity.class);
            intent.putExtra("resume_id", resume_id);
            intent.putExtra("experience_id", "");
            intent.putExtra("company", "");
            intent.putExtra("start_time", "0");
            intent.putExtra("end_time", "0");
            intent.putExtra("description", "");
            startActivity(intent);
            refreshFlag = true;
        }
    }

    @Override
    public void onRefresh() {
        page = 1;
        getExperienceList(page, false, true);
    }

    @Override
    public void onItemClick(View view, int position) {
        Intent intent = new Intent(ExperienceListActivity.this, EditExperienceActivity.class);
        intent.putExtra("resume_id", resume_id);
        intent.putExtra("experience_id", experience.getData().get(position).getId());
        intent.putExtra("company", experience.getData().get(position).getCompany());
        intent.putExtra("start_time", experience.getData().get(position).getStart_time());
        intent.putExtra("end_time", experience.getData().get(position).getEnd_time());
        intent.putExtra("description", experience.getData().get(position).getDescription());
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
                moreFab.show();
            }
        }
    };

    private void showNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.VISIBLE);
            return;
        }

        ViewStub stub = (ViewStub) findViewById(R.id.experience_null_lay);
        nullView = stub.inflate();
        ImageView nullImg = (ImageView) nullView.findViewById(R.id.null_img);
        nullImg.setImageResource(R.drawable.img_experience_null);
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
                        delExperience(data.get(deletePosition).getId());
                    }
                })
                .build();
    }

    private void getExperienceList(int mPage, final boolean isAddMore, final boolean isPullToRefresh) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("page", mPage);
        map.put("resume_id", resume_id);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_EXPERIENCE_LIST, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getExperienceList : " + responseInfo.result.toString());
                        if (!isAddMore) {
                            data.clear();
                        }
//
                        Type type = new TypeToken<Experience>() {
                        }.getType();
                        experience = gson.fromJson(responseInfo.result.toString(), type);
                        if (experience.getCode() == 1) {
                            data.addAll(experience.getData());
                            page = experience.getPagination().getPage();
                            pageSize = experience.getPagination().getPageSize();
                            total = experience.getPagination().getTotal();

                            adapter.notifyDataSetChanged();
                            if (isAddMore) {
                                experienceList.scrollToPosition((page - 1) * pageSize);
                            }

                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }

                            if (data.size() < RESUME_LIMIT) {
                                if (data.size() < total) {
                                    moreFab.setVisibility(View.VISIBLE);
                                }
                            }
                        } else {
                            if (checkLoginState(experience.getCode(), ExperienceListActivity.this)) {
                                Toast.makeText(ExperienceListActivity.this, experience.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                        if (isPullToRefresh) {
                            swipeRefreshLayout.setRefreshing(false);
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(ExperienceListActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    private void delExperience(String id) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("experience_id", id);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.DELETE,
                URL_EXPERIENCE,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("delExperience : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            if (checkLoginState((int)map.get("code"), ExperienceListActivity.this)) {
                                Toast.makeText(ExperienceListActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            Toast.makeText(ExperienceListActivity.this, R.string.delete_complete, Toast.LENGTH_SHORT).show();
                            page = 1;
                            getExperienceList(page, false, true);
                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(ExperienceListActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
