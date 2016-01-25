package com.zhoucl.p.suchengzhaopin.ui;

import android.os.AsyncTask;
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
import com.google.gson.reflect.TypeToken;
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
import com.zhoucl.p.suchengzhaopin.adapter.CityAdapter;
import com.zhoucl.p.suchengzhaopin.adapter.ProvinceAdapter;
import com.zhoucl.p.suchengzhaopin.model.City;
import com.zhoucl.p.suchengzhaopin.model.NativePlace;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;
import com.zhoucl.wheel.OnWheelChangedListener;
import com.zhoucl.wheel.WheelView;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by zhoucl on 2015/7/22.
 */
public class ResumePersonalInfoActivity extends BaseActivity implements View.OnClickListener,
        DatePickerDialog.OnDateSetListener, OnWheelChangedListener {
    private static String URL_RESUME = IP + "/app/resume_api/resume";//POST resume_id real_name gender birthday
    // native_place political_status work_start_time mobile email school major 姓名与手机为必填项

    private static String resume_id;
    private static String real_name, gender, birthday, native_place, work_start_time, mobile, email, school, major, degree, political_status;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.save_btn)
    private Button saveBtn;

    @ViewInject(R.id.personal_details_name_lay)
    private RelativeLayout nameLay;

    @ViewInject(R.id.personal_details_gender_lay)
    private RelativeLayout genderLay;

    @ViewInject(R.id.personal_details_birthday_lay)
    private RelativeLayout birthdayLay;

    @ViewInject(R.id.personal_details_native_lay)
    private RelativeLayout nativeLay;

    @ViewInject(R.id.personal_details_work_start_time_lay)
    private RelativeLayout workStartTimeLay;

    @ViewInject(R.id.personal_details_phone_lay)
    private RelativeLayout phoneLay;

    @ViewInject(R.id.personal_details_email_lay)
    private RelativeLayout emailLay;

    @ViewInject(R.id.personal_details_school_lay)
    private RelativeLayout schoolLay;

    @ViewInject(R.id.personal_details_major_lay)
    private RelativeLayout majorLay;

    @ViewInject(R.id.personal_details_degree_lay)
    private RelativeLayout degreeLay;

    @ViewInject(R.id.personal_details_political_lay)
    private RelativeLayout politicalLay;

    private TextView nameLeftText, genderLeftText, birthdayLeftText, nativeLeftText, workStartTimeLeftText,
            phoneLeftText, emailLeftText, schoolLeftText, majorLeftText, degreeLeftText, politicalLeftText;
    private TextView nameRightText, genderRightText, birthdayRightText, nativeRightText, workStartTimeRightText,
            phoneRightText, emailRightText, schoolRightText, majorRightText, degreeRightText, politicalRightText;

    private EditText nameLeftEdit, phoneLeftEdit, emailLeftEdit, schoolLeftEdit, majorLeftEdit;
    private TextView nameRightConfirm, phoneRightConfirm, emailRightConfirm, schoolRightConfirm, majorRightConfirm;

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;

    private String[] leftText, genderText;

    private MaterialDialog genderDialog;
    private SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private Calendar calendar = Calendar.getInstance();
    private DatePickerDialog datePickerDialog;
    private MaterialDialog nativeDialog;
    private WheelView provinceWheel, cityWheel;
    private String mCurrentProvinceName, mCurrentCityName;
    private List<City> cityList;
    private MaterialDialog degreeDialog;
    private MaterialDialog politicalStatusDialog;

    private Map<String, Object> valueMap = new HashMap<>();
    private boolean isBirthdayPicker = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_resume_personal_info);
        ViewUtils.inject(this);

        Bundle bundle = getIntent().getExtras();
        resume_id = bundle.getString("resume_id");
        real_name = bundle.getString("real_name");
        gender = bundle.getString("gender");
        birthday = bundle.getString("birthday");
        native_place = bundle.getString("native_place");
        work_start_time = bundle.getString("work_start_time");
        mobile = bundle.getString("mobile");
        email = bundle.getString("email");
        school = bundle.getString("school");
        major = bundle.getString("major");
        degree = bundle.getString("degree");
        political_status = bundle.getString("political_status");

        valueMap.put("real_name", real_name);
        valueMap.put("gender", gender);
        valueMap.put("birthday", birthday);
        valueMap.put("native_place", native_place);
        valueMap.put("political_status", political_status);
        valueMap.put("work_start_time", work_start_time);
        valueMap.put("mobile", mobile);
        valueMap.put("email", email);
        valueMap.put("school", school);
        valueMap.put("major", major);
        valueMap.put("degree", degree);

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.configCurrentHttpCacheExpiry(1000);

        new LoadDistrictData().execute();

        init();
    }

    public void init() {
        leftText = getResources().getStringArray(R.array.personal_info_left_text);
        genderText = getResources().getStringArray(R.array.gender);

        nameLeftText = (TextView) nameLay.findViewById(R.id.edit_left_text);
        genderLeftText = (TextView) genderLay.findViewById(R.id.non_edit_left_text);
        birthdayLeftText = (TextView) birthdayLay.findViewById(R.id.non_edit_left_text);
        nativeLeftText = (TextView) nativeLay.findViewById(R.id.non_edit_left_text);
        workStartTimeLeftText = (TextView) workStartTimeLay.findViewById(R.id.non_edit_left_text);
        phoneLeftText = (TextView) phoneLay.findViewById(R.id.edit_left_text);
        emailLeftText = (TextView) emailLay.findViewById(R.id.edit_left_text);
        schoolLeftText = (TextView) schoolLay.findViewById(R.id.edit_left_text);
        majorLeftText = (TextView) majorLay.findViewById(R.id.edit_left_text);
        degreeLeftText = (TextView) degreeLay.findViewById(R.id.non_edit_left_text);
        politicalLeftText = (TextView) politicalLay.findViewById(R.id.non_edit_left_text);

        nameRightText = (TextView) nameLay.findViewById(R.id.edit_right_text);
        genderRightText = (TextView) genderLay.findViewById(R.id.non_edit_right_text);
        birthdayRightText = (TextView) birthdayLay.findViewById(R.id.non_edit_right_text);
        nativeRightText = (TextView) nativeLay.findViewById(R.id.non_edit_right_text);
        workStartTimeRightText = (TextView) workStartTimeLay.findViewById(R.id.non_edit_right_text);
        phoneRightText = (TextView) phoneLay.findViewById(R.id.edit_right_text);
        emailRightText = (TextView) emailLay.findViewById(R.id.edit_right_text);
        schoolRightText = (TextView) schoolLay.findViewById(R.id.edit_right_text);
        majorRightText = (TextView) majorLay.findViewById(R.id.edit_right_text);
        degreeRightText = (TextView) degreeLay.findViewById(R.id.non_edit_right_text);
        politicalRightText = (TextView) politicalLay.findViewById(R.id.non_edit_right_text);

        nameLeftEdit = (EditText) nameLay.findViewById(R.id.edit_left_edit);
        phoneLeftEdit = (EditText) phoneLay.findViewById(R.id.edit_left_edit);
        emailLeftEdit = (EditText) emailLay.findViewById(R.id.edit_left_edit);
        schoolLeftEdit = (EditText) schoolLay.findViewById(R.id.edit_left_edit);
        majorLeftEdit = (EditText) majorLay.findViewById(R.id.edit_left_edit);

        nameRightConfirm = (TextView) nameLay.findViewById(R.id.edit_right_confirm);
        phoneRightConfirm = (TextView) phoneLay.findViewById(R.id.edit_right_confirm);
        emailRightConfirm = (TextView) emailLay.findViewById(R.id.edit_right_confirm);
        schoolRightConfirm = (TextView) schoolLay.findViewById(R.id.edit_right_confirm);
        majorRightConfirm = (TextView) majorLay.findViewById(R.id.edit_right_confirm);

        titleText.setText(R.string.personal_details);

        nameLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_name_personal), null, null, null);
        genderLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_gender), null, null, null);
        birthdayLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_birthday), null, null, null);
        nativeLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_native_place), null, null, null);
        workStartTimeLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_work_start_time), null, null, null);
        phoneLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_phone_number), null, null, null);
        emailLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_email_address), null, null, null);
        schoolLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_educational_background), null, null, null);
        majorLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_major), null, null, null);
        degreeLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_degree), null, null, null);
        politicalLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_political_status), null, null, null);

        nameLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_name_personal), null, null, null);
        phoneLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_phone_number), null, null, null);
        emailLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_email_address), null, null, null);
        schoolLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_educational_background), null, null, null);
        majorLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_major), null, null, null);

        nameLeftText.setText(leftText[0]);
        genderLeftText.setText(leftText[1]);
        birthdayLeftText.setText(leftText[2]);
        nativeLeftText.setText(leftText[3]);
        workStartTimeLeftText.setText(leftText[4]);
        phoneLeftText.setText(leftText[5]);
        emailLeftText.setText(leftText[6]);
        schoolLeftText.setText(leftText[7]);
        majorLeftText.setText(leftText[8]);
        degreeLeftText.setText(leftText[9]);
        politicalLeftText.setText(leftText[10]);

        nameRightText.setText(real_name);
        genderRightText.setText(genderText[Integer.parseInt(gender)]);
        if (!birthday.equals("0")) {
            birthdayRightText.setText(DateFormat.format("yyyy-MM-dd", Long.parseLong(birthday) * 1000L).toString());
        }
        nativeRightText.setText(native_place);
        if (!work_start_time.equals("0")) {
            workStartTimeRightText.setText(DateFormat.format("yyyy-MM-dd", Long.parseLong(work_start_time) * 1000L).toString());
        }
        phoneRightText.setText(mobile);
        emailRightText.setText(email);
        schoolRightText.setText(school);
        majorRightText.setText(major);
        degreeRightText.setText(degree);
        politicalRightText.setText(political_status);

        titleBackBtn.setOnClickListener(this);
        saveBtn.setOnClickListener(this);
        nameLay.setOnClickListener(this);
        genderLay.setOnClickListener(this);
        birthdayLay.setOnClickListener(this);
        nativeLay.setOnClickListener(this);
        workStartTimeLay.setOnClickListener(this);
        phoneLay.setOnClickListener(this);
        emailLay.setOnClickListener(this);
        schoolLay.setOnClickListener(this);
        majorLay.setOnClickListener(this);
        degreeLay.setOnClickListener(this);
        politicalLay.setOnClickListener(this);
        nameRightConfirm.setOnClickListener(this);
        phoneRightConfirm.setOnClickListener(this);
        emailRightConfirm.setOnClickListener(this);
        schoolRightConfirm.setOnClickListener(this);
        majorRightConfirm.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            new MaterialDialog.Builder(ResumePersonalInfoActivity.this)
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
        } else if (v.equals(nameLay)) {
            nameLeftText.setVisibility(View.GONE);
            nameRightText.setVisibility(View.GONE);
            nameLeftEdit.setVisibility(View.VISIBLE);
            nameRightConfirm.setVisibility(View.VISIBLE);
            nameLeftEdit.setText(nameRightText.getText().toString());
            nameLeftEdit.requestFocus();
            showSoftInput(nameLeftEdit);
        } else if (v.equals(genderLay)) {
            showGenderDialog();
        } else if (v.equals(birthdayLay)) {
            isBirthdayPicker = true;
            showDatePickerDialog(birthdayRightText.getText().toString());
        } else if (v.equals(nativeLay)) {
            showNativeDialog();
        } else if (v.equals(workStartTimeLay)) {
            isBirthdayPicker = false;
            showDatePickerDialog(workStartTimeRightText.getText().toString());
        } else if (v.equals(phoneLay)) {
            phoneLeftText.setVisibility(View.GONE);
            phoneRightText.setVisibility(View.GONE);
            phoneLeftEdit.setVisibility(View.VISIBLE);
            phoneRightConfirm.setVisibility(View.VISIBLE);
            phoneLeftEdit.setText(phoneRightText.getText().toString());
            phoneLeftEdit.requestFocus();
            showSoftInput(phoneLeftEdit);
        } else if (v.equals(emailLay)) {
            emailLeftText.setVisibility(View.GONE);
            emailRightText.setVisibility(View.GONE);
            emailLeftEdit.setVisibility(View.VISIBLE);
            emailRightConfirm.setVisibility(View.VISIBLE);
            emailLeftEdit.setText(emailRightText.getText().toString());
            emailLeftEdit.requestFocus();
            showSoftInput(emailLeftEdit);
        } else if (v.equals(schoolLay)) {
            schoolLeftText.setVisibility(View.GONE);
            schoolRightText.setVisibility(View.GONE);
            schoolLeftEdit.setVisibility(View.VISIBLE);
            schoolRightConfirm.setVisibility(View.VISIBLE);
            schoolLeftEdit.setText(schoolRightText.getText().toString());
            schoolLeftEdit.requestFocus();
            showSoftInput(schoolLeftEdit);
        } else if (v.equals(majorLay)) {
            majorLeftText.setVisibility(View.GONE);
            majorRightText.setVisibility(View.GONE);
            majorLeftEdit.setVisibility(View.VISIBLE);
            majorRightConfirm.setVisibility(View.VISIBLE);
            majorLeftEdit.setText(majorRightText.getText().toString());
            majorLeftEdit.requestFocus();
            showSoftInput(majorLeftEdit);
        } else if (v.equals(degreeLay)) {
            showDegreeDialog();
        } else if (v.equals(politicalLay)) {
            showPoliticalStatusDialog();
        } else if (v.equals(nameRightConfirm)) {
            nameLeftText.setVisibility(View.VISIBLE);
            nameRightText.setVisibility(View.VISIBLE);
            nameLeftEdit.setVisibility(View.GONE);
            nameRightConfirm.setVisibility(View.GONE);
            nameRightText.setText(nameLeftEdit.getText().toString());
            valueMap.put("real_name", nameLeftEdit.getText().toString());
        } else if (v.equals(phoneRightConfirm)) {
            phoneLeftText.setVisibility(View.VISIBLE);
            phoneRightText.setVisibility(View.VISIBLE);
            phoneLeftEdit.setVisibility(View.GONE);
            phoneRightConfirm.setVisibility(View.GONE);
            phoneRightText.setText(phoneLeftEdit.getText().toString());
            valueMap.put("mobile", phoneLeftEdit.getText().toString());
        } else if (v.equals(emailRightConfirm)) {
            emailLeftText.setVisibility(View.VISIBLE);
            emailRightText.setVisibility(View.VISIBLE);
            emailLeftEdit.setVisibility(View.GONE);
            emailRightConfirm.setVisibility(View.GONE);
            emailRightText.setText(emailLeftEdit.getText().toString());
            valueMap.put("email", emailLeftEdit.getText().toString());
        } else if (v.equals(schoolRightConfirm)) {
            schoolLeftText.setVisibility(View.VISIBLE);
            schoolRightText.setVisibility(View.VISIBLE);
            schoolLeftEdit.setVisibility(View.GONE);
            schoolRightConfirm.setVisibility(View.GONE);
            schoolRightText.setText(schoolLeftEdit.getText().toString());
            valueMap.put("school", schoolLeftEdit.getText().toString());
        } else if (v.equals(majorRightConfirm)) {
            majorLeftText.setVisibility(View.VISIBLE);
            majorRightText.setVisibility(View.VISIBLE);
            majorLeftEdit.setVisibility(View.GONE);
            majorRightConfirm.setVisibility(View.GONE);
            majorRightText.setText(majorLeftEdit.getText().toString());
            valueMap.put("major", majorLeftEdit.getText().toString());
        } else if (v.equals(saveBtn)) {
            if (nameRightConfirm.isShown()) {
                nameRightConfirm.performClick();
            }
            if (phoneRightConfirm.isShown()) {
                phoneRightConfirm.performClick();
            }
            if (emailRightConfirm.isShown()) {
                emailRightConfirm.performClick();
            }
            if (schoolRightConfirm.isShown()) {
                schoolRightConfirm.performClick();
            }
            if (majorRightConfirm.isShown()) {
                majorRightConfirm.performClick();
            }
            editResume();
        }
    }

    public void showGenderDialog() {
        if (genderDialog == null) {
            genderDialog = new MaterialDialog.Builder(this)
                    .title(leftText[1])
                    .items(R.array.gender)
                    .itemsCallback(new MaterialDialog.ListCallback() {
                        @Override
                        public void onSelection(MaterialDialog materialDialog, View view, int i, CharSequence charSequence) {
                            genderRightText.setText(charSequence.toString());
                            valueMap.put("gender", i);
                        }
                    }).build();
        }
        genderDialog.show();
    }

    public void showDegreeDialog() {
        if (degreeDialog == null) {
            List<String> degreeList = null;
            try {
                degreeList = string2List(configPreferences.getString(BaseActivity.CONFIG_KEY_DEGREE, ""));
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            degreeDialog = new MaterialDialog.Builder(this)
                    .title(leftText[9])
                    .items(degreeList.toArray(new String[degreeList.size()]))
                    .itemsCallback(new MaterialDialog.ListCallback() {
                        @Override
                        public void onSelection(MaterialDialog materialDialog, View view, int i, CharSequence charSequence) {
                            degreeRightText.setText(charSequence.toString());
                            valueMap.put("degree", charSequence.toString());
                        }
                    }).build();
        }
        degreeDialog.show();
    }

    public void showPoliticalStatusDialog() {
        if (politicalStatusDialog == null) {
            List<String> politicalStatusList = null;
            try {
                politicalStatusList = string2List(configPreferences.getString(BaseActivity.CONFIG_KEY_POLITICAL_STATUS, ""));
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            politicalStatusDialog = new MaterialDialog.Builder(this)
                    .title(leftText[10])
                    .items(politicalStatusList.toArray(new String[politicalStatusList.size()]))
                    .itemsCallback(new MaterialDialog.ListCallback() {
                        @Override
                        public void onSelection(MaterialDialog materialDialog, View view, int i, CharSequence charSequence) {
                            politicalRightText.setText(charSequence.toString());
                            valueMap.put("political_status", charSequence.toString());
                        }
                    }).build();
        }
        politicalStatusDialog.show();
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
        datePickerDialog = DatePickerDialog.newInstance(ResumePersonalInfoActivity.this,
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH));

        datePickerDialog.show(getFragmentManager(), "DatePickerDialog");
    }

    public void showNativeDialog() {
        if (nativeDialog == null) {
            nativeDialog = new MaterialDialog.Builder(this)
                    .title(leftText[3])
                    .customView(R.layout.custom_view_wheel, true)
                    .positiveText(R.string.confirm)
                    .negativeText(android.R.string.cancel)
                    .callback(new MaterialDialog.ButtonCallback() {
                        @Override
                        public void onPositive(MaterialDialog dialog) {
                            if (cityList.size() > 0) {
                                mCurrentCityName = cityList.get(cityWheel.getCurrentItem()).getName();
                            }
                            native_place = mCurrentProvinceName + " " + mCurrentCityName;
                            nativeRightText.setText(native_place);
                            valueMap.put("native_place", native_place);
                        }
                    }).build();
            provinceWheel = (WheelView) nativeDialog.getCustomView().findViewById(R.id.province_wheel);
            cityWheel = (WheelView) nativeDialog.getCustomView().findViewById(R.id.city_wheel);
            provinceWheel.addChangingListener(this);
            cityWheel.addChangingListener(this);

            provinceWheel.setViewAdapter(new ProvinceAdapter(this, nativePlace.getCity_list()));
            provinceWheel.setVisibleItems(5);
            cityWheel.setVisibleItems(5);
            updateCities();
        }

        nativeDialog.show();
    }

    private class LoadDistrictData extends AsyncTask<String, Integer, String> {

        @Override
        protected void onPreExecute() {
            showProgressDialog();
        }

        @Override
        protected String doInBackground(String... params) {
            try {
                InputStream is = getAssets().open("city_.json");
                byte[] buffer = new byte[is.available()];
                is.read(buffer);
                String json = new String(buffer, "utf-8");
                is.close();
                Type type = new TypeToken<NativePlace>() {
                }.getType();
                nativePlace = gson.fromJson(json, type);
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String s) {
            cancelProgressDialog();
        }
    }

    /**
     * 根据当前的省，更新市WheelView的信息
     */
    private void updateCities() {
        int pCurrent = provinceWheel.getCurrentItem();
        mCurrentProvinceName = nativePlace.getCity_list().get(pCurrent).getProvince();
        cityList = nativePlace.getCity_list().get(pCurrent).getCity();
        if (cityList == null) {
            cityList = new ArrayList<>();
            mCurrentCityName = "";
        }

        cityWheel.setViewAdapter(new CityAdapter(this, cityList));
        cityWheel.setCurrentItem(0);
    }

    @Override
    public void onDateSet(DatePickerDialog datePickerDialog, int year, int monthOfYear, int dayOfMonth) {
        String key = "";
        String value = "";
        calendar.set(year, monthOfYear, dayOfMonth);
        value = String.valueOf(calendar.getTimeInMillis());
        if (isBirthdayPicker) {
            key = "birthday";
            birthdayRightText.setText(simpleDateFormat.format(calendar.getTime()));
            birthday = value;
        } else {
            key = "work_start_time";
            workStartTimeRightText.setText(simpleDateFormat.format(calendar.getTime()));
            work_start_time = value;
        }
        valueMap.put(key, Long.parseLong(value) / 1000L);
    }

    @Override
    public void onChanged(WheelView wheel, int oldValue, int newValue) {
        if (wheel == provinceWheel) {
            updateCities();
        } else if (wheel == cityWheel) {
        }
    }

    private void editResume() {
        RequestParams params = new RequestParams();
        params.addBodyParameter("resume_id", resume_id);
        for (String key : valueMap.keySet()) {
            params.addBodyParameter(key, valueMap.get(key).toString());
        }

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_RESUME,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("editResume : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            Toast.makeText(ResumePersonalInfoActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                        } else {
                            finish();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(ResumePersonalInfoActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }
}
