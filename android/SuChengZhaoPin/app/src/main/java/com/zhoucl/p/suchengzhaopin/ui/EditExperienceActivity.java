package com.zhoucl.p.suchengzhaopin.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;
import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.wdullaer.materialdatetimepicker.date.DatePickerDialog;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

/**
 * Created by zhoucl on 2015/7/29.
 */
public class EditExperienceActivity extends BaseActivity implements View.OnClickListener,
        DatePickerDialog.OnDateSetListener {
    private static String URL_EXPERIENCE = IP + "/app/resume_api/experience";//POST resume_id experience_id（该参数不传即为新增）
    // company start_time end_time description

    private String resume_id, experience_id, company, start_time, end_time, description;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.experience_company_lay)
    private RelativeLayout companyLay;

    @ViewInject(R.id.experience_start_time_lay)
    private RelativeLayout startTimeLay;

    @ViewInject(R.id.experience_end_time_lay)
    private RelativeLayout endTimeLay;

    @ViewInject(R.id.experience_edit)
    private EditText experienceEdit;

    @ViewInject(R.id.save_btn)
    private Button saveBtn;

    private TextView companyLeftText, startLeftText, endLeftText;
    private TextView companyRightText, startRightText, endRightText;
    private EditText companyLeftEdit;
    private TextView companyRightConfirm;

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;

    private SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private Calendar calendar = Calendar.getInstance();
    private DatePickerDialog datePickerDialog;

    private MaterialDialog endTimeDialog;

    private boolean isStartPicker = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_edit_experience);
        ViewUtils.inject(this);

        Bundle bundle = getIntent().getExtras();
        resume_id = bundle.getString("resume_id");
        experience_id = bundle.getString("experience_id");
        company = bundle.getString("company");
        start_time = bundle.getString("start_time");
        end_time = bundle.getString("end_time");
        description = bundle.getString("description");

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();

        init();
    }

    public void init() {
        titleText.setText(R.string.work_experience);

        companyLeftText = (TextView) companyLay.findViewById(R.id.edit_left_text);
        startLeftText = (TextView) startTimeLay.findViewById(R.id.non_edit_left_text);
        endLeftText = (TextView) endTimeLay.findViewById(R.id.non_edit_left_text);
        companyRightText = (TextView) companyLay.findViewById(R.id.edit_right_text);
        startRightText = (TextView) startTimeLay.findViewById(R.id.non_edit_right_text);
        endRightText = (TextView) endTimeLay.findViewById(R.id.non_edit_right_text);
        companyLeftEdit = (EditText) companyLay.findViewById(R.id.edit_left_edit);
        companyRightConfirm = (TextView) companyLay.findViewById(R.id.edit_right_confirm);

        companyLeftText.setText(R.string.company_name);
        startLeftText.setText(R.string.job_start_time);
        endLeftText.setText(R.string.job_end_time);

        companyRightText.setText(company);
        if (!start_time.equals("0")) {
            startRightText.setText(DateFormat.format("yyyy-MM-dd", Long.parseLong(start_time) * 1000L).toString());
        }
        if (!end_time.equals("0")) {
            if (end_time.equals("-1")) {
                endRightText.setText(R.string.till_now);
            } else {
                endRightText.setText(DateFormat.format("yyyy-MM-dd", Long.parseLong(end_time) * 1000L).toString());
            }
        }
        experienceEdit.setText(description);

        titleBackBtn.setOnClickListener(this);
        companyLay.setOnClickListener(this);
        startTimeLay.setOnClickListener(this);
        endTimeLay.setOnClickListener(this);
        companyRightConfirm.setOnClickListener(this);
        saveBtn.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            new MaterialDialog.Builder(EditExperienceActivity.this)
                    .content(R.string.not_save_tip)
                    .positiveText(R.string.confirm)
                    .negativeText(android.R.string.cancel)
                    .callback(new MaterialDialog.ButtonCallback() {
                        @Override
                        public void onPositive(MaterialDialog dialog) {
                            super.onPositive(dialog);
                            finish();
                        }
                    })
                    .show();
        } else if (v.equals(companyLay)) {
            companyLeftText.setVisibility(View.GONE);
            companyRightText.setVisibility(View.GONE);
            companyLeftEdit.setVisibility(View.VISIBLE);
            companyRightConfirm.setVisibility(View.VISIBLE);
            companyLeftEdit.setText(companyRightText.getText().toString());
            companyLeftEdit.requestFocus();
            showSoftInput(companyLeftEdit);
        } else if (v.equals(startTimeLay)) {
            isStartPicker = true;
            showDatePickerDialog(startRightText.getText().toString());
        } else if (v.equals(endTimeLay)) {
            showGenderDialog();
        } else if (v.equals(companyRightConfirm)) {
            companyLeftText.setVisibility(View.VISIBLE);
            companyRightText.setVisibility(View.VISIBLE);
            companyLeftEdit.setVisibility(View.GONE);
            companyRightConfirm.setVisibility(View.GONE);
            companyRightText.setText(companyLeftEdit.getText().toString());
        } else if (v.equals(saveBtn)) {
            if (companyRightConfirm.isShown()) {
                companyRightConfirm.performClick();
            }
            editExperience();
        }
    }

    public void showDatePickerDialog(String value) {
        if (!TextUtils.isEmpty(value)) {
            try {
                Date date = simpleDateFormat.parse(value);
                calendar.setTime(date);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        datePickerDialog = DatePickerDialog.newInstance(EditExperienceActivity.this,
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH));

        datePickerDialog.show(getFragmentManager(), "DatePickerDialog");
    }

    public void showGenderDialog() {
        if (endTimeDialog == null) {
            endTimeDialog = new MaterialDialog.Builder(this)
                    .title(R.string.job_end_time)
                    .items(R.array.select_end_time)
                    .itemsCallback(new MaterialDialog.ListCallback() {
                        @Override
                        public void onSelection(MaterialDialog materialDialog, View view, int i, CharSequence charSequence) {
                            if (i == 0) {
                                end_time = "-1";
                                endRightText.setText(R.string.till_now);
                            } else {
                                isStartPicker = false;
                                showDatePickerDialog(endRightText.getText().toString());
                            }
                        }
                    }).build();
        }
        endTimeDialog.show();
    }

    @Override
    public void onDateSet(DatePickerDialog datePickerDialog, int year, int monthOfYear, int dayOfMonth) {
        calendar.set(year, monthOfYear, dayOfMonth);
        if (isStartPicker) {
            startRightText.setText(simpleDateFormat.format(calendar.getTime()));
            start_time = String.valueOf(calendar.getTimeInMillis() / 1000L);
        } else {
            endRightText.setText(simpleDateFormat.format(calendar.getTime()));
            end_time = String.valueOf(calendar.getTimeInMillis() / 1000L);
        }
    }

    private void editExperience() {
        RequestParams params = new RequestParams();
        params.addBodyParameter("resume_id", resume_id);
        params.addBodyParameter("experience_id", experience_id);
        params.addBodyParameter("company", companyRightText.getText().toString());
        params.addBodyParameter("start_time", start_time);
        params.addBodyParameter("end_time", end_time);
        params.addBodyParameter("description", experienceEdit.getText().toString());

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_EXPERIENCE,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("editExperience : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            Toast.makeText(EditExperienceActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                        } else {
                            finish();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(EditExperienceActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }
}
