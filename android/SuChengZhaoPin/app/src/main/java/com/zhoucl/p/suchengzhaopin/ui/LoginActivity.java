package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
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
import com.zhoucl.p.suchengzhaopin.model.UserInfo;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.lang.reflect.Type;
import java.util.HashMap;

/**
 * Created by zhoucl on 2015/7/14.
 */
public class LoginActivity extends BaseActivity implements RadioGroup.OnCheckedChangeListener, View.OnClickListener {

    private static String URL_REGISTER = IP + "/app/user_api/register";//POST email password
    private static String URL_LOGIN = IP + "/app/user_api/login";//POST email password
    private static String URL_FIND_PWD = IP + "/passport/find_pwd";

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.top_tab)
    private RadioGroup topTab;

    @ViewInject(R.id.login_tab)
    private RadioButton loginTab;

    @ViewInject(R.id.register_tab)
    private RadioButton registerTab;

    @ViewInject(R.id.login_lay)
    private LinearLayout loginLay;

    @ViewInject(R.id.register_lay)
    private LinearLayout registerLay;

    @ViewInject(R.id.login_name_edit)
    private EditText loginNameEdit;

    @ViewInject(R.id.login_psw_edit)
    private EditText loginPswEdit;

    @ViewInject(R.id.login_btn)
    private Button loginBtn;

    @ViewInject(R.id.find_psw_text)
    private TextView findPswText;

    @ViewInject(R.id.register_name_edit)
    private EditText registerNameEdit;

    @ViewInject(R.id.register_psw_edit)
    private EditText registerPswEdit;

    @ViewInject(R.id.register_btn)
    private Button registerBtn;

    private Gson gson;
    private UserInfo userInfo;
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            finish();
        }
    };

    private HttpUtilsWithToken httpUtilsWithToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_login);
        ViewUtils.inject(this); //注入view和事件

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        isLoginSuccessful = false;

        titleText.setText(R.string.login);

        topTab.setOnCheckedChangeListener(this);
        backBtn.setOnClickListener(this);
        registerBtn.setOnClickListener(this);
        loginBtn.setOnClickListener(this);
        findPswText.setOnClickListener(this);
    }

    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        switch (checkedId) {
            case R.id.login_tab:
                setTab(getResources().getColor(R.color.white),
                        getResources().getColor(R.color.text_default),
                        View.VISIBLE,
                        View.GONE);
                titleText.setText(R.string.login);
                break;
            case R.id.register_tab:
                setTab(getResources().getColor(R.color.text_default),
                        getResources().getColor(R.color.white),
                        View.GONE,
                        View.VISIBLE);
                titleText.setText(R.string.register);
                break;
            default:
                break;
        }
    }

    private void setTab(int leftColor, int rightColor, int leftVis, int rightVis) {
        loginTab.setTextColor(leftColor);
        registerTab.setTextColor(rightColor);
        loginLay.setVisibility(leftVis);
        registerLay.setVisibility(rightVis);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(backBtn)) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm.isActive(loginNameEdit)
                    || imm.isActive(loginPswEdit)
                    || imm.isActive(registerNameEdit)
                    || imm.isActive(registerPswEdit)) {
                imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                handler.sendEmptyMessageDelayed(0, 100);
            } else {
                finish();
            }
        } else if (v.equals(loginBtn)) {
            doLogin(loginNameEdit.getText().toString(),
                    loginPswEdit.getText().toString());
        } else if (v.equals(registerBtn)) {
            doRegister(registerNameEdit.getText().toString(),
                    registerPswEdit.getText().toString());
        } else if (v.equals(findPswText)) {
            Intent intent = new Intent(LoginActivity.this, WebViewBox.class);
            intent.putExtra("url", URL_FIND_PWD);
            intent.putExtra("title", getResources().getString(R.string.find_psw_title));
            startActivity(intent);
        }
    }

    /**
     * 注册
     *
     * @param email
     * @param password
     */
    private void doRegister(String email, String password) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("email", email);
        params.addBodyParameter("password", password);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_REGISTER,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("doRegister : " + responseInfo.result.toString());
                        HashMap<String, Object> map = parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            Toast.makeText(LoginActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(LoginActivity.this, R.string.register_complete, Toast.LENGTH_SHORT).show();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(LoginActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

    /**
     * 登录
     *
     * @param email
     * @param password
     */
    private void doLogin(String email, String password) {
        RequestParams params = new RequestParams();
        params.addBodyParameter("email", email);
        params.addBodyParameter("password", password);

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_LOGIN,
                params,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("doLogin : " + responseInfo.result.toString());
                        Type type = new TypeToken<UserInfo>() {
                        }.getType();
                        userInfo = gson.fromJson(responseInfo.result.toString(), type);
                        if (userInfo.getCode() != 1) {
                            Toast.makeText(LoginActivity.this, userInfo.getError(), Toast.LENGTH_SHORT).show();
                            isLoginSuccessful = false;
                        } else {
                            SharedPreferences.Editor editor = userInfoPreferences.edit();
                            editor.putString(KEY_EMAIL, userInfo.getUser().getEmail());
                            editor.putString(KEY_REAL_NAME, userInfo.getUser().getReal_name());
                            editor.putString(KEY_MOBILE, userInfo.getUser().getMobile());
                            editor.putString(KEY_IS_ACTIVE, userInfo.getUser().getIs_active());
                            editor.putString(KEY_TOKEN, userInfo.getToken());
                            editor.commit();
                            TOKEN = userInfo.getToken();
                            isLoginSuccessful = true;
                            finish();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(LoginActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }
}
