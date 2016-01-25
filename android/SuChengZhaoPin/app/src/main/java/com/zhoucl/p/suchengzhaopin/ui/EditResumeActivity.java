package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
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
import com.zhoucl.p.suchengzhaopin.model.ResumeDetails;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.lang.reflect.Type;
import java.util.HashMap;

/**
 * Created by zhoucl on 2015/7/21.
 */
public class EditResumeActivity extends BaseActivity implements View.OnClickListener {
    private static String URL_RESUME = IP + "/app/resume_api/resume";//GET resume_id
    private static String URL_RESUME_NAME = IP + "/app/resume_api/resume_name";//POST resume_id resume_name

    private static String resume_id;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.edit_name_lay)
    private RelativeLayout editNameLay;

    @ViewInject(R.id.edit_name_right_text)
    private TextView editNameRightText;

    @ViewInject(R.id.edit_name_left_text)
    private TextView editNameLeftText;

    @ViewInject(R.id.edit_user_info_lay)
    private RelativeLayout editUserInfoLay;

    @ViewInject(R.id.edit_user_info_right_text)
    private TextView editUserInfoRightText;

    @ViewInject(R.id.edit_self_assessment_lay)
    private RelativeLayout editSelfAssessmentLay;

    @ViewInject(R.id.edit_self_assessment_right_text)
    private TextView editSelfAssessmentRightText;

    @ViewInject(R.id.edit_work_experience_lay)
    private RelativeLayout editWorkExperienceLay;

    @ViewInject(R.id.edit_work_experience_right_text)
    private TextView editWorkExperienceRightText;

    @ViewInject(R.id.edit_name_right_confirm)
    private TextView editNameRightConfirm;

    @ViewInject(R.id.edit_name_left_edit)
    private EditText editNameLeftEdit;

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;
    private ResumeDetails resumeDetails;

    private boolean refreshFlag = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_edit_resume);
        ViewUtils.inject(this);

        Bundle bundle = getIntent().getExtras();
        resume_id = bundle.getString("resume_id");

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(1000);
        init();
    }

    public void init() {
        titleText.setText(R.string.edit_resume);

        titleBackBtn.setOnClickListener(this);
        editNameLay.setOnClickListener(this);
        editNameRightConfirm.setOnClickListener(this);
        editUserInfoLay.setOnClickListener(this);
        editSelfAssessmentLay.setOnClickListener(this);
        editWorkExperienceLay.setOnClickListener(this);

        getResume();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (refreshFlag) {
            getResume();
            refreshFlag = false;
        }
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            finish();
        } else if (v.equals(editNameLay)) {
            editNameLeftText.setVisibility(View.GONE);
            editNameRightText.setVisibility(View.GONE);
            editNameLeftEdit.setVisibility(View.VISIBLE);
            editNameRightConfirm.setVisibility(View.VISIBLE);
            editNameLeftEdit.setText(editNameLeftText.getText().toString());
            editNameLeftEdit.requestFocus();
            showSoftInput(editNameLeftEdit);
        } else if (v.equals(editNameRightConfirm)) {
            editNameLeftText.setText(editNameLeftEdit.getText().toString());
            editResumeName(resume_id, editNameLeftEdit.getText().toString());
        } else if (v.equals(editUserInfoLay)) {
            refreshFlag = true;
            Intent intent = new Intent(EditResumeActivity.this, ResumePersonalInfoActivity.class);
            intent.putExtra("resume_id", resume_id);
            intent.putExtra("real_name", resumeDetails.getData().getReal_name());
            intent.putExtra("gender", resumeDetails.getData().getGender());
            intent.putExtra("birthday", resumeDetails.getData().getBirthday());
            intent.putExtra("native_place", resumeDetails.getData().getNative_place());
            intent.putExtra("work_start_time", resumeDetails.getData().getWork_start_time());
            intent.putExtra("mobile", resumeDetails.getData().getMobile());
            intent.putExtra("email", resumeDetails.getData().getEmail());
            intent.putExtra("school", resumeDetails.getData().getSchool());
            intent.putExtra("major", resumeDetails.getData().getMajor());
            intent.putExtra("degree", resumeDetails.getData().getDegree());
            intent.putExtra("political_status", resumeDetails.getData().getPolitical_status());
            startActivity(intent);
        } else if (v.equals(editSelfAssessmentLay)) {
            refreshFlag = true;
            Intent intent = new Intent(EditResumeActivity.this, EvaluationActivity.class);
            intent.putExtra("resume_id", resume_id);
            intent.putExtra("evaluation", resumeDetails.getData().getEvaluation());
            startActivity(intent);
        } else if (v.equals(editWorkExperienceLay)) {
            refreshFlag = true;
            Intent intent = new Intent(EditResumeActivity.this, ExperienceListActivity.class);
            intent.putExtra("resume_id", resume_id);
            startActivity(intent);
        }
    }

    private void getResume() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("resume_id", resume_id);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_RESUME, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getResume : " + responseInfo.result.toString());
                        Type type = new TypeToken<ResumeDetails>() {
                        }.getType();
                        resumeDetails = gson.fromJson(responseInfo.result.toString(), type);
                        if (resumeDetails.getCode() == 1) {
                            editNameLeftText.setText(resumeDetails.getData().getResume_name());
                            if (resumeDetails.getData().getPersonal_info_completed().equals("1")) {
                                editUserInfoRightText.setTextColor(getResources().getColor(R.color.text_blue));
                                editUserInfoRightText.setText(R.string.full);
                            } else {
                                editUserInfoRightText.setTextColor(getResources().getColor(R.color.text_yellow));
                                editUserInfoRightText.setText(R.string.not_full);
                            }

                            if (resumeDetails.getData().getEvaluation_completed().equals("1")) {
                                editSelfAssessmentRightText.setTextColor(getResources().getColor(R.color.text_blue));
                                editSelfAssessmentRightText.setText(R.string.full);
                            } else {
                                editSelfAssessmentRightText.setTextColor(getResources().getColor(R.color.text_yellow));
                                editSelfAssessmentRightText.setText(R.string.not_full);
                            }

                            if (resumeDetails.getData().getExperience_completed().equals("1")) {
                                editWorkExperienceRightText.setTextColor(getResources().getColor(R.color.text_blue));
                                editWorkExperienceRightText.setText(R.string.full);
                            } else {
                                editWorkExperienceRightText.setTextColor(getResources().getColor(R.color.text_yellow));
                                editWorkExperienceRightText.setText(R.string.not_full);
                            }
                        } else {
                            if (checkLoginState(resumeDetails.getCode(), EditResumeActivity.this)) {
                                Toast.makeText(EditResumeActivity.this, resumeDetails.getError(), Toast.LENGTH_SHORT).show();
                            }
                        }

                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(EditResumeActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    private void editResumeName(String resume_id, String resume_name) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("resume_id", resume_id);
        params.addBodyParameter("resume_name", resume_name);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_RESUME_NAME,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("editResumeName : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());
//
                        if ((int)map.get("code") != 1) {
                            Toast.makeText(EditResumeActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                        } else {
                            editNameLeftText.setVisibility(View.VISIBLE);
                            editNameRightText.setVisibility(View.VISIBLE);
                            editNameLeftEdit.setVisibility(View.GONE);
                            editNameRightConfirm.setVisibility(View.GONE);
                            editNameLeftEdit.getEditableText().clear();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(EditResumeActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }
}
