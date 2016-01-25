package com.zhoucl.p.suchengzhaopin.ui;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.util.HashMap;

/**
 * Created by zhoucl on 2015/7/30.
 */
public class EditUserInfoActivity extends BaseActivity implements View.OnClickListener {
    private static String URL_EDIT = IP + "/app/user_api/edit";//POST mobile real_name

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.user_edit_name_lay)
    private RelativeLayout nameLay;

    @ViewInject(R.id.user_edit_mobile_lay)
    private RelativeLayout mobileLay;

    @ViewInject(R.id.user_edit_email_lay)
    private RelativeLayout emailLay;

    @ViewInject(R.id.user_edit_email_right_text)
    private TextView emailRightText;

    @ViewInject(R.id.save_btn)
    private Button saveBtn;

    private TextView nameLeftText, mobileLeftText;
    private TextView nameRightText, mobileRightText;
    private EditText nameLeftEdit, mobileLeftEdit;
    private TextView nameRightConfirm, mobileRightConfirm;

    private HttpUtilsWithToken httpUtilsWithToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_edit_user_info);
        ViewUtils.inject(this);

        httpUtilsWithToken = new HttpUtilsWithToken();
        init();
    }

    public void init() {
        titleText.setText(R.string.edit_personal_details);

        nameLeftText = (TextView) nameLay.findViewById(R.id.edit_left_text);
        mobileLeftText = (TextView) mobileLay.findViewById(R.id.edit_left_text);

        nameRightText = (TextView) nameLay.findViewById(R.id.edit_right_text);
        mobileRightText = (TextView) mobileLay.findViewById(R.id.edit_right_text);

        nameLeftEdit = (EditText) nameLay.findViewById(R.id.edit_left_edit);
        mobileLeftEdit = (EditText) mobileLay.findViewById(R.id.edit_left_edit);

        nameRightConfirm = (TextView) nameLay.findViewById(R.id.edit_right_confirm);
        mobileRightConfirm = (TextView) mobileLay.findViewById(R.id.edit_right_confirm);

        nameLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_name_personal), null, null, null);
        mobileLeftText.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_phone_number), null, null, null);

        nameLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_name_personal), null, null, null);
        mobileLeftEdit.setCompoundDrawablesWithIntrinsicBounds(getResources().getDrawable(R.drawable.icon_phone_number), null, null, null);

        nameLeftText.setText(R.string.name);
        mobileLeftText.setText(R.string.mobile);

        nameRightText.setText(userInfoPreferences.getString(KEY_REAL_NAME, ""));
        mobileRightText.setText(userInfoPreferences.getString(KEY_MOBILE, ""));
        emailRightText.setText(userInfoPreferences.getString(KEY_EMAIL, ""));

        nameLay.setOnClickListener(this);
        mobileLay.setOnClickListener(this);
        backBtn.setOnClickListener(this);
        saveBtn.setOnClickListener(this);
        nameRightConfirm.setOnClickListener(this);
        mobileRightConfirm.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(backBtn)) {
            finish();
        } else if (v.equals(nameLay)) {
            nameLeftText.setVisibility(View.GONE);
            nameRightText.setVisibility(View.GONE);
            nameLeftEdit.setVisibility(View.VISIBLE);
            nameRightConfirm.setVisibility(View.VISIBLE);
            nameLeftEdit.setText(nameRightText.getText().toString());
            nameLeftEdit.requestFocus();
            showSoftInput(nameLeftEdit);
        } else if (v.equals(mobileLay)) {
            mobileLeftText.setVisibility(View.GONE);
            mobileRightText.setVisibility(View.GONE);
            mobileLeftEdit.setVisibility(View.VISIBLE);
            mobileRightConfirm.setVisibility(View.VISIBLE);
            mobileLeftEdit.setText(mobileRightText.getText().toString());
            mobileLeftEdit.requestFocus();
            showSoftInput(mobileLeftEdit);
        } else if (v.equals(nameRightConfirm)) {
            nameLeftText.setVisibility(View.VISIBLE);
            nameRightText.setVisibility(View.VISIBLE);
            nameLeftEdit.setVisibility(View.GONE);
            nameRightConfirm.setVisibility(View.GONE);
            nameRightText.setText(nameLeftEdit.getText().toString());
        } else if (v.equals(mobileRightConfirm)) {
            mobileLeftText.setVisibility(View.VISIBLE);
            mobileRightText.setVisibility(View.VISIBLE);
            mobileLeftEdit.setVisibility(View.GONE);
            mobileRightConfirm.setVisibility(View.GONE);
            mobileRightText.setText(mobileLeftEdit.getText().toString());
        } else if (v.equals(saveBtn)) {
            if (nameRightConfirm.isShown()) {
                nameRightConfirm.performClick();
            }
            if (mobileRightConfirm.isShown()) {
                mobileRightConfirm.performClick();
            }
            doSave(mobileRightText.getText().toString(), nameRightText.getText().toString());
        }
    }

    private void doSave(final String mobile, final String real_name) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("mobile", mobile);
        params.addBodyParameter("real_name", real_name);
        HttpUtilsWithToken httpUtilsWithToken = new HttpUtilsWithToken();
        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_EDIT,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("doSave : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int) map.get("code") != 1) {
                            if (checkLoginState((int) map.get("code"), EditUserInfoActivity.this)) {
                                Toast.makeText(EditUserInfoActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            SharedPreferences.Editor editor = userInfoPreferences.edit();
                            editor.putString(KEY_REAL_NAME, real_name);
                            editor.putString(KEY_MOBILE, mobile);
                            editor.commit();
                            finish();
                            Toast.makeText(EditUserInfoActivity.this, R.string.save_successful, Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(EditUserInfoActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
