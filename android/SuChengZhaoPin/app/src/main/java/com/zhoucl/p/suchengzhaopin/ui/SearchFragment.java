package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
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
import com.zhoucl.p.suchengzhaopin.adapter.DistrictGridAdapter;
import com.zhoucl.p.suchengzhaopin.adapter.JobsAdapter;
import com.zhoucl.p.suchengzhaopin.model.Job;
import com.zhoucl.p.suchengzhaopin.util.DividerItemDecoration;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static android.support.v7.widget.RecyclerView.OnScrollListener;

/**
 * Created by zhoucl on 2015/6/29.
 */
public class SearchFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener,
        JobsAdapter.OnItemClickListener, View.OnClickListener {

    private static String URL_JOB_LIST = BaseActivity.IP + "/app/api/job_list";//GET q：搜索项 district：地区 page：翻页

    @ViewInject(R.id.select_district_lay)
    LinearLayout selectDistrictLay;

    @ViewInject(R.id.district_text)
    TextView districtText;

    @ViewInject(R.id.district_arrow)
    static
    CheckBox districtArrow;

    @ViewInject(R.id.search_edit)
    EditText searchEdit;

    @ViewInject(R.id.swipe_refresh_layout)
    SwipeRefreshLayout swipeRefreshLayout;

    @ViewInject(R.id.job_list)
    RecyclerView jobList;

    @ViewInject(R.id.more_jobs_fab)
    FloatingActionButton moreJobsFab;

    private LinearLayoutManager layoutManager;
    private JobsAdapter jobsAdapter;
    private List<Job.Data> data = new ArrayList<Job.Data>();

    private View rootView;//缓存Fragment view

    private static View districtView;
    private GridView districtGrid;
    private DistrictGridAdapter districtAdapter;

    private List<String> districtList;//区域
    public static int districtClickPosition;
    private String currentDistrict;
    private int currentDistrictPosition;

    private static Animation pushInAnim;
    private static Animation pushOutAnim;

    private Gson gson;
    private Job jobs;
    private int page = 1;
    private int pageSize;
    private int total;

    private View nullView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (rootView == null) {
            rootView = inflater.inflate(R.layout.fragment_search, null);

            //****************************初始化******************************
            pushInAnim = AnimationUtils.loadAnimation(getActivity(), R.anim.push_top_in);
            pushOutAnim = AnimationUtils.loadAnimation(getActivity(), R.anim.push_top_out);

            gson = new Gson();
            ViewUtils.inject(this, rootView); //注入view和事件

            try {
                districtList = BaseActivity.string2List(MainActivity.configPreferences.getString(BaseActivity.CONFIG_KEY_DISTRICT, ""));
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }

            if (districtList.size() > 0) {
                currentDistrict = BaseActivity.configPreferences.getString(BaseActivity.KEY_CURRENT_DISTRICT, districtList.get(0));
                currentDistrictPosition = BaseActivity.configPreferences.getInt(BaseActivity.KEY_CURRENT_DISTRICT_POSITION, 0);
                if (currentDistrictPosition > districtList.size()) {
                    currentDistrict = districtList.get(0);
                    currentDistrictPosition = 0;
                }
            }
            SharedPreferences.Editor editor = BaseActivity.configPreferences.edit();
            editor.putString(BaseActivity.KEY_CURRENT_DISTRICT, currentDistrict);
            editor.putInt(BaseActivity.KEY_CURRENT_DISTRICT_POSITION, currentDistrictPosition);
            editor.commit();
            districtText.setText(currentDistrict);

            jobList.setFocusable(true);
            jobList.setFocusableInTouchMode(true);
            jobList.requestFocus();

            searchEdit.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                    if (actionId == EditorInfo.IME_ACTION_SEARCH || (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                        //
                        page = 1;
                        getJobs(v.getText().toString(), currentDistrict, page, false, false);
                        return true;
                    }
                    return false;
                }
            });

            moreJobsFab.attachToRecyclerView(jobList);

            swipeRefreshLayout.setOnRefreshListener(this);
            layoutManager = new LinearLayoutManager(getActivity());
            layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
            jobList.setLayoutManager(layoutManager);
            jobList.setHasFixedSize(true);
            jobList.addItemDecoration(new DividerItemDecoration(getActivity(), DividerItemDecoration.VERTICAL_LIST));
            jobsAdapter = new JobsAdapter(data, getActivity());
            jobList.setAdapter(jobsAdapter);

            jobsAdapter.setOnItemClickListener(this);
            jobList.addOnScrollListener(scrollListener);

            selectDistrictLay.setOnClickListener(this);
            moreJobsFab.setOnClickListener(this);

            getJobs("", currentDistrict, page, false, false);
            //****************************初始化******************************
        }
        //缓存的rootView需要判断是否已经被加过parent， 如果有parent需要从parent删除，要不然会发生这个rootview已经有parent的错误。
        ViewGroup parent = (ViewGroup) rootView.getParent();
        if (parent != null) {
            parent.removeView(rootView);
        }

        return rootView;
    }

    /*
    初始化选择区域View
     */
    public void showDistrictWindow() {
        districtArrow.setChecked(!districtArrow.isChecked());
        if (districtView != null) {
            districtClickPosition = currentDistrictPosition;
            districtAdapter.notifyDataSetChanged();
            districtView.setVisibility(View.VISIBLE);
            districtView.startAnimation(pushInAnim);
            return;
        }

        ViewStub stub = (ViewStub) getActivity().findViewById(R.id.district_layout);
        districtView = stub.inflate();

        LinearLayout districtBgLay = (LinearLayout) districtView.findViewById(R.id.district_bg_lay);
        districtGrid = (GridView) districtView.findViewById(R.id.district_grid);

        districtBgLay.getBackground().setAlpha(100);

        districtGrid.setOnItemClickListener(itemClickListener);
        districtAdapter = new DistrictGridAdapter(districtList, getActivity());
        districtGrid.setAdapter(districtAdapter);
        districtClickPosition = currentDistrictPosition;
        districtAdapter.notifyDataSetChanged();
        districtView.startAnimation(pushInAnim);
    }

    public static void cancelDistrictWindow() {
        if (districtView != null) {
            districtArrow.setChecked(!districtArrow.isChecked());
            districtView.setVisibility(View.GONE);
            districtView.startAnimation(pushOutAnim);
        }
    }

    private void showNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.VISIBLE);
            return;
        }

        ViewStub stub = (ViewStub) getActivity().findViewById(R.id.search_null_lay);
        nullView = stub.inflate();
        ImageView nullImg = (ImageView) nullView.findViewById(R.id.null_img);
        nullImg.setImageResource(R.drawable.img_search_null);
    }

    private void cancelNullView() {
        if (nullView != null) {
            nullView.setVisibility(View.GONE);
        }
    }

    public AdapterView.OnItemClickListener itemClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            cancelDistrictWindow();
            districtClickPosition = position;
            currentDistrictPosition = position;
            districtAdapter.notifyDataSetChanged();
            currentDistrict = districtList.get(position);
            districtText.setText(currentDistrict);
            page = 1;
            getJobs(searchEdit.getText().toString(), currentDistrict, page, false, false);
        }
    };

    private void getJobs(String q, String district, int mPage, final boolean isAddMore, final boolean isPullToRefresh) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("q", q);
        map.put("district", district);
        map.put("page", mPage);

        ((MainActivity) getActivity()).httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                ((MainActivity) getActivity()).urlFormat(URL_JOB_LIST, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        ((MainActivity) getActivity()).showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getJobs : " + responseInfo.result.toString());
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

                            jobsAdapter.notifyDataSetChanged();
                            if (isAddMore) {
                                jobList.scrollToPosition((page - 1) * pageSize);
                            }

                            if (data.size() == 0) {
                                showNullView();
                            } else {
                                cancelNullView();
                            }

                            if (data.size() < total) {
                                moreJobsFab.setVisibility(View.VISIBLE);
                            } else {
                                moreJobsFab.setVisibility(View.INVISIBLE);
                            }

                        } else {
                            if (((MainActivity) getActivity()).checkLoginState(jobs.getCode(), getActivity())) {
                                Toast.makeText(getActivity(), jobs.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        ((MainActivity) getActivity()).cancelProgressDialog();
                        if (isPullToRefresh) {
                            swipeRefreshLayout.setRefreshing(false);
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(getActivity(), s, Toast.LENGTH_SHORT).show();
                        ((MainActivity) getActivity()).cancelProgressDialog();
                    }
                });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (districtView != null) {
            if (districtView.isShown()) {
                cancelDistrictWindow();
            }
        }
        SharedPreferences.Editor editor = BaseActivity.configPreferences.edit();
        editor.putString(BaseActivity.KEY_CURRENT_DISTRICT, currentDistrict);
        editor.putInt(BaseActivity.KEY_CURRENT_DISTRICT_POSITION, currentDistrictPosition);
        editor.commit();
    }

    public static boolean onBackPress() {
        if (districtView != null) {
            if (districtView.isShown()) {
                cancelDistrictWindow();
                return true;
            }
        }
        return false;
    }

    @Override
    public void onRefresh() {
        page = 1;
        getJobs(searchEdit.getText().toString(), currentDistrict, page, false, true);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(selectDistrictLay)) {
            if (districtView != null) {
                if (!districtView.isShown()) {
                    showDistrictWindow();
                } else {
                    cancelDistrictWindow();
                }
            } else {
                showDistrictWindow();
            }
        } else if (v.equals(moreJobsFab)) {
            if (data.size() < total) {
                page++;
                getJobs(searchEdit.getText().toString(), currentDistrict, page, true, false);
            } else {
                Toast.makeText(getActivity(), R.string.no_more, Toast.LENGTH_SHORT).show();
            }
        }
    }

    @Override
    public void onItemClick(View view, int position) {
        Intent intent = new Intent(getActivity(), JobDetailsActivity.class);
        intent.putExtra("job_id", data.get(position).getJob_id());
        startActivity(intent);
    }

    public OnScrollListener scrollListener = new OnScrollListener() {
        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            if (layoutManager.findLastVisibleItemPosition() == (data.size() - 1)) {
                moreJobsFab.show();
            }
        }
    };
}
