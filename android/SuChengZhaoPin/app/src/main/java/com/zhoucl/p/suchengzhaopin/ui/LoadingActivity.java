package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Toast;

import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.Config;
import com.zhoucl.p.suchengzhaopin.model.UserInfo;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;

/**
 * Created by zhoucl on 2015/7/10.
 */
public class LoadingActivity extends BaseActivity {

    private static String URL_APPCONFIG = IP + "/app/api/appconfig";//GET
    private static String URL_VERIFY_TOKEN = IP + "/app/user_api/verify_token";//GET token

    private Gson gson;
    private Config config;
    private UserInfo userInfo;

    private HttpUtilsWithToken httpUtilsWithToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        TOKEN = userInfoPreferences.getString(KEY_TOKEN, "");
        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();
        getConfig();
    }

    private void getConfig() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("version", getAppVersionCode(LoadingActivity.this));
        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                urlFormat(URL_APPCONFIG, map),
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getConfig : " + responseInfo.result.toString());
                        Type type = new TypeToken<Config>() {
                        }.getType();
                        config = gson.fromJson(responseInfo.result.toString(), type);

                        if (config.getCode() == 1) {
                            RESUME_LIMIT = config.getData().getResume_limit();

                            SharedPreferences.Editor editor = configPreferences.edit();
                            try {
                                editor.putString(CONFIG_KEY_DEGREE, list2String(config.getData().getDegree()));
                                editor.putString(CONFIG_KEY_DISTRICT, list2String(config.getData().getDistrict()));
                                editor.putString(CONFIG_KEY_POLITICAL_STATUS, list2String(config.getData().getPolitical_status()));
                                editor.commit();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        } else {
                        }

                        if (config.getData().getForce_update() == 1) {
                            //强制更新
                            new MaterialDialog.Builder(LoadingActivity.this)
                                    .content(R.string.force_update_content)
                                    .positiveText(R.string.confirm)
                                    .cancelable(false)
                                    .show();
                        } else {
                            if (!TOKEN.equals("")) {
                                verifyToken();
                            } else {
                                startActivity(new Intent(LoadingActivity.this, MainActivity.class));
                                finish();
                            }
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(LoadingActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void verifyToken() {
        httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                URL_VERIFY_TOKEN,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("verifyToken : " + responseInfo.result.toString());
                        Type type = new TypeToken<UserInfo>() {
                        }.getType();
                        userInfo = gson.fromJson(responseInfo.result.toString(), type);
                        if (userInfo.getCode() == 1) {
                            SharedPreferences.Editor editor = userInfoPreferences.edit();
                            editor.putString(KEY_EMAIL, userInfo.getUser().getEmail());
                            editor.putString(KEY_REAL_NAME, userInfo.getUser().getReal_name());
                            editor.putString(KEY_MOBILE, userInfo.getUser().getMobile());
                            editor.putString(KEY_IS_ACTIVE, userInfo.getUser().getIs_active());
                            editor.putString(KEY_TOKEN, userInfo.getToken());
                            editor.commit();
                            TOKEN = userInfo.getToken();
                        } else {
//                            TOKEN = "";
//                            SharedPreferences.Editor editor = BaseActivity.userInfoPreferences.edit();
//                            editor.clear();
//                            editor.commit();
                        }
                        startActivity(new Intent(LoadingActivity.this, MainActivity.class));
                        finish();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(LoadingActivity.this, s, Toast.LENGTH_SHORT).show();
                    }
                });
    }

    /**
     * 返回当前程序版本名
     */
    public static String getAppVersionCode(Context context) {
        String versionCode = "";
        try {
            // ---get the package info---
            PackageManager pm = context.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);
//            versionName = pi.versionName;
            versionCode = String.valueOf(pi.versionCode);
            if (versionCode == null || versionCode.length() <= 0) {
                return "";
            }
        } catch (Exception e) {
            LogUtils.e("VersionInfo Exception", e);
        }
        return versionCode;
    }
}
