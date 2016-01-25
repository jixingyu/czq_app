package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewStub;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageButton;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

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
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.adapter.ApplyResumesAdapter;
import com.zhoucl.p.suchengzhaopin.model.AddResume;
import com.zhoucl.p.suchengzhaopin.model.Details;
import com.zhoucl.p.suchengzhaopin.model.Resume;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;
import com.zhoucl.p.suchengzhaopin.view.MyGridView;
import com.zhoucl.p.suchengzhaopin.view.MyListView;

import org.json.JSONArray;
import org.json.JSONException;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

/**
 * Created by zhoucl on 2015/7/16.
 */
public class JobDetailsActivity extends BaseActivity implements RadioGroup.OnCheckedChangeListener,
        View.OnClickListener {

    private static String URL_JOB = IP + "/app/api/job";//GET job_id
    private static String URL_FAVORITE = IP + "/app/api/favorite";//POST job_id
    private static String URL_APPLY = IP + "/app/api/apply";//POST job_id resume_id
    private static String URL_RESUME_LIST = IP + "/app/resume_api/resume_list";//GET page
    private static String URL_ADD_RESUME = IP + "/app/resume_api/add_resume";//GET

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.top_tab)
    private RadioGroup topTab;

    @ViewInject(R.id.job_details_tab)
    private RadioButton jobDetailsTab;

    @ViewInject(R.id.company_details_tab)
    private RadioButton companyDetailsTab;

    @ViewInject(R.id.job_details_scrollview)
    private ScrollView jobDetailsScrollview;

    @ViewInject(R.id.company_details_scrollview)
    private ScrollView companyDetailsScrollview;

    @ViewInject(R.id.apply_btn)
    private Button applyBtn;

    @ViewInject(R.id.job_name)
    private TextView jobName;

    @ViewInject(R.id.update_time)
    private TextView updateTime;

    @ViewInject(R.id.company_name)
    private TextView companyName;

    @ViewInject(R.id.favorite_btn)
    private CheckBox favoriteBtn;

    @ViewInject(R.id.degree_limit)
    private TextView degreeLimit;

    @ViewInject(R.id.salary)
    private TextView salary;

    @ViewInject(R.id.job_experience)
    private TextView jobExperience;

    @ViewInject(R.id.job_number)
    private TextView jobNumber;

    @ViewInject(R.id.job_type)
    private TextView jobType;

    @ViewInject(R.id.benefit_grid)
    private MyGridView benefitGridView;

    @ViewInject(R.id.requirement_list)
    private MyListView requirementListView;

    @ViewInject(R.id.company_name_dark)
    private TextView companyNameDark;

    @ViewInject(R.id.company_industry)
    private TextView companyIndustry;

    @ViewInject(R.id.company_number)
    private TextView companyNumber;

    @ViewInject(R.id.company_address)
    private TextView companyAddress;

    @ViewInject(R.id.company_description)
    private TextView companyDescription;

    private static String job_id;
    private Gson gson;
    private Details details;
    private List<String> benefitList = new ArrayList<>();
    private List<String> requirementList = new ArrayList<>();
    private ArrayAdapter<String> benefitAdapter;
    private ArrayAdapter<String> requirementAdapter;

    private HttpUtilsWithToken httpUtilsWithToken;

    private View selectView;
    private TextView applySelectTitle;
    private MyListView applySelectList;
    private Button applyCreateBtn, applyCancelBtn;
    private Resume resumes;
    private List<Resume.Data> resumeData = new ArrayList<>();
    private ApplyResumesAdapter resumesAdapter;

    private AddResume addResume;

    public Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            cancelSelectView();
            getDetails();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_details);
        ViewUtils.inject(this); //注入view和事件

        Bundle bundle = getIntent().getExtras();
        job_id = bundle.getString("job_id");

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(2000);
        init();
    }

    public void init() {
        titleText.setText(R.string.details);

        backBtn.setOnClickListener(this);
        topTab.setOnCheckedChangeListener(this);
        favoriteBtn.setOnClickListener(this);
        applyBtn.setOnClickListener(this);
        benefitGridView.setEnabled(false);
        requirementListView.setEnabled(false);

        benefitAdapter = new ArrayAdapter<String>(this, R.layout.item_benefit, benefitList);
        benefitGridView.setAdapter(benefitAdapter);

        requirementAdapter = new ArrayAdapter<String>(this, R.layout.item_requirement, requirementList);
        requirementListView.setAdapter(requirementAdapter);

        getDetails();
    }

    @Override
    public void onClick(View v) {
        if (v.equals(backBtn)) {
            finish();
        } else if (v.equals(favoriteBtn)) {
            doFavorite();
        } else if (v.equals(applyBtn)) {
            getResumeList();
        } else if (v.equals(applyCancelBtn)) {
            cancelSelectView();
        } else if (v.equals(applyCreateBtn)) {
            cancelSelectView();
            addResume();
        }
    }

    private void showSelectView() {
        if (selectView != null) {
            selectView.setVisibility(View.VISIBLE);
            return;
        }

        ViewStub stub = (ViewStub) findViewById(R.id.apply_select_lay);
        selectView = stub.inflate();
        applySelectTitle = (TextView) selectView.findViewById(R.id.apply_select_title);
        applySelectList = (MyListView) selectView.findViewById(R.id.apply_select_list);
        applyCancelBtn = (Button) selectView.findViewById(R.id.apply_cancel_btn);
        applyCreateBtn = (Button) selectView.findViewById(R.id.apply_create_btn);

        resumesAdapter = new ApplyResumesAdapter(resumeData, this, URL_APPLY, job_id, handler);
        applySelectList.setAdapter(resumesAdapter);

        applyCancelBtn.setOnClickListener(this);
        applyCreateBtn.setOnClickListener(this);
    }

    private void cancelSelectView() {
        if (selectView != null) {
            selectView.setVisibility(View.GONE);
        }
    }

    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        switch (checkedId) {
            case R.id.job_details_tab:
                setTab(getResources().getColor(R.color.white),
                        getResources().getColor(R.color.text_default),
                        View.VISIBLE,
                        View.GONE);
                break;
            case R.id.company_details_tab:
                setTab(getResources().getColor(R.color.text_default),
                        getResources().getColor(R.color.white),
                        View.GONE,
                        View.VISIBLE);
                break;
            default:
                break;
        }
    }

    private void setTab(int leftColor, int rightColor, int leftVis, int rightVis) {
        jobDetailsTab.setTextColor(leftColor);
        companyDetailsTab.setTextColor(rightColor);
        jobDetailsScrollview.setVisibility(leftVis);
        companyDetailsScrollview.setVisibility(rightVis);
    }

    private void getDetails() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("job_id", job_id);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_JOB, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getDetails : " + responseInfo.result.toString());
                        Type type = new TypeToken<Details>() {
                        }.getType();
                        details = gson.fromJson(responseInfo.result.toString(), type);
                        if (details.getCode() == 1) {
                            jobName.setText(details.getData().getName());
                            updateTime.setText(details.getData().getUpdate_time());
                            companyName.setText(details.getData().getC_name());
                            if (details.getData().getIs_favorite() == 1) {
                                favoriteBtn.setChecked(true);
                            }
                            salary.setText(String.format(getResources().getString(R.string.salary_unit), details.getData().getSalary()));
                            degreeLimit.setText(details.getData().getDegree());
                            jobExperience.setText(details.getData().getWorking_years());
                            jobNumber.setText(details.getData().getRecruit_number());
                            jobType.setText(details.getData().getJob_type());
                            //解析福利
                            benefitList.clear();
                            if (!TextUtils.isEmpty(details.getData().getBenefit())) {
                                try {
                                    JSONArray benefitJArray = new JSONArray(details.getData().getBenefit());
                                    for (int i = 0; i < benefitJArray.length(); i++) {
                                        benefitList.add(benefitJArray.get(i).toString());
                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                            //解析任职要求
                            requirementList.clear();
                            if (details.getData().getRequirement().contains("\r\n")) {
                                requirementList.addAll(Arrays.asList(details.getData().getRequirement().split("\r\n")));
                            } else {
                                requirementList.add(details.getData().getRequirement());
                            }

                            benefitAdapter.notifyDataSetChanged();
                            requirementAdapter.notifyDataSetChanged();

                            companyNameDark.setText(details.getData().getC_name());
                            companyIndustry.setText(details.getData().getC_industry());
                            companyNumber.setText(String.format(getResources().getString(R.string.company_staff_unit), details.getData().getC_number()));
                            companyAddress.setText(details.getData().getC_address());
                            companyDescription.setText(details.getData().getC_description());
                            if (details.getData().getApplied() == 0) {
                                applyBtn.setText(R.string.apply_job);
                            } else {
                                applyBtn.setText(R.string.already_apply_job);
                                applyBtn.setEnabled(false);
                            }
                        } else {
                            if (checkLoginState(details.getCode(), JobDetailsActivity.this)) {
                                Toast.makeText(JobDetailsActivity.this, details.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(JobDetailsActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    private void doFavorite() {
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
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int) map.get("code") != 1) {
                            favoriteBtn.setChecked(!favoriteBtn.isChecked());
                            if (checkLoginState((int) map.get("code"), JobDetailsActivity.this)) {
                                Toast.makeText(JobDetailsActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            if (favoriteBtn.isChecked()) {
                                Toast.makeText(JobDetailsActivity.this, R.string.do_favorite_successful, Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(JobDetailsActivity.this, R.string.cancel_favorite_successful, Toast.LENGTH_SHORT).show();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(JobDetailsActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void getResumeList() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("page", 1);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_RESUME_LIST, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getResumeList : " + responseInfo.result.toString());

                        Type type = new TypeToken<Resume>() {
                        }.getType();
                        resumes = gson.fromJson(responseInfo.result.toString(), type);
                        if (resumes.getCode() == 1) {
                            resumeData.clear();
                            resumeData.addAll(resumes.getData());

                            showSelectView();

                            if (resumeData.size() == 0) {
                                applySelectTitle.setText(R.string.must_have_a_resume);
                                applySelectList.setVisibility(View.GONE);
                                applyCreateBtn.setVisibility(View.VISIBLE);
                            } else {
                                applySelectTitle.setText(R.string.pls_select_a_resume);
                                if (!applySelectList.isShown()) {
                                    applySelectList.setVisibility(View.VISIBLE);
                                    applyCreateBtn.setVisibility(View.GONE);
                                }
                            }

                            resumesAdapter.notifyDataSetChanged();
                        } else {
                            if (checkLoginState(resumes.getCode(), JobDetailsActivity.this)) {
                                Toast.makeText(JobDetailsActivity.this, resumes.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(JobDetailsActivity.this, s, Toast.LENGTH_SHORT).show();
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
                            Intent intent = new Intent(JobDetailsActivity.this, EditResumeActivity.class);
                            intent.putExtra("resume_id", String.valueOf(addResume.getData().getId()));
                            startActivity(intent);
                        } else {
                            if (checkLoginState(addResume.getCode(), JobDetailsActivity.this)) {
                                Toast.makeText(JobDetailsActivity.this, addResume.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(JobDetailsActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
            if (selectView != null) {
                if (selectView.isShown()) {
                    cancelSelectView();
                    return false;
                }
            }
        }
        return super.onKeyDown(keyCode, event);
    }
}
