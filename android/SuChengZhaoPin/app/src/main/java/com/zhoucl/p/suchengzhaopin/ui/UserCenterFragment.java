package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.lidroid.xutils.ViewUtils;
import com.lidroid.xutils.exception.HttpException;
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.zhoucl.p.suchengzhaopin.R;

import java.util.HashMap;

import de.hdodenhof.circleimageview.CircleImageView;

/**
 * Created by zhoucl on 2015/6/29.
 */
public class UserCenterFragment extends Fragment implements View.OnClickListener {

    private static String URL_LOGOUT = BaseActivity.IP + "/app/user_api/logout";//GET

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.user_center_title_lay)
    private LinearLayout userCenterTitleLay;

    @ViewInject(R.id.user_head_img)
    private CircleImageView userHeadImg;

    @ViewInject(R.id.user_name_text)
    private TextView userNameText;

    @ViewInject(R.id.user_mail_text)
    private TextView userMailText;

    @ViewInject(R.id.logout_btn)
    private TextView logoutBtn;

    @ViewInject(R.id.my_resume_lay)
    private RelativeLayout myResumeLay;

    @ViewInject(R.id.send_record_lay)
    private RelativeLayout sendRecordLay;

    @ViewInject(R.id.invite_lay)
    private RelativeLayout inviteLay;

    @ViewInject(R.id.my_collection_lay)
    private RelativeLayout myCollectionLay;

    @ViewInject(R.id.edit_personal_details_lay)
    private RelativeLayout editPersonalDetailsLay;

    private boolean resumeFlag = false;//未登录
    private boolean refreshFlag = false;//登录已过期

    private View rootView;//缓存Fragment view

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (rootView == null) {
            rootView = inflater.inflate(R.layout.fragment_user_center, null);

            //****************************初始化******************************
            ViewUtils.inject(this, rootView); //注入view和事件

            titleText.setText(R.string.user_center);
            backBtn.setVisibility(View.GONE);

            if (BaseActivity.TOKEN.equals("")) {
                userCenterTitleLay.setEnabled(true);
                userHeadImg.setImageResource(R.drawable.icon_default_head_img);
                userNameText.setText(R.string.click_to_login);
            } else {
                userCenterTitleLay.setEnabled(false);
                logoutBtn.setVisibility(View.VISIBLE);
                userHeadImg.setImageResource(R.drawable.icon_online_head_img);
                userNameText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_REAL_NAME, ""));
                userMailText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_EMAIL, ""));
            }

            userCenterTitleLay.setOnClickListener(this);
            logoutBtn.setOnClickListener(this);
            myResumeLay.setOnClickListener(this);
            sendRecordLay.setOnClickListener(this);
            inviteLay.setOnClickListener(this);
            myCollectionLay.setOnClickListener(this);
            editPersonalDetailsLay.setOnClickListener(this);
            //****************************初始化******************************
        }
        //缓存的rootView需要判断是否已经被加过parent， 如果有parent需要从parent删除，要不然会发生这个rootview已经有parent的错误。
        ViewGroup parent = (ViewGroup) rootView.getParent();
        if (parent != null) {
            parent.removeView(rootView);
        }

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (resumeFlag) {
            if (BaseActivity.isLoginSuccessful) {
                userCenterTitleLay.setEnabled(false);
                logoutBtn.setVisibility(View.VISIBLE);
                userHeadImg.setImageResource(R.drawable.icon_online_head_img);
                userNameText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_REAL_NAME, ""));
                userMailText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_EMAIL, ""));
            }
            resumeFlag = false;
        }
        if (refreshFlag) {
            if (BaseActivity.TOKEN.equals("")) {
                userCenterTitleLay.setEnabled(true);
                userHeadImg.setImageResource(R.drawable.icon_default_head_img);
                userNameText.setText(R.string.click_to_login);
            } else {
                userNameText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_REAL_NAME, ""));
                userMailText.setText(BaseActivity.userInfoPreferences.getString(BaseActivity.KEY_EMAIL, ""));
            }
            refreshFlag = false;
        }
    }

    @Override
    public void onClick(View v) {
        if (v.equals(userCenterTitleLay)) {
            resumeFlag = true;
            startActivity(new Intent(getActivity(), LoginActivity.class));
        } else if (v.equals(logoutBtn)) {
            logout();
        } else if (v.equals(myResumeLay)) {
            if (!TextUtils.isEmpty(BaseActivity.TOKEN)){
                refreshFlag = true;
                Intent intent = new Intent(getActivity(), MyResumeActivity.class);
                startActivity(intent);
            } else {
                resumeFlag = true;
                Intent intent = new Intent(getActivity(), LoginActivity.class);
                startActivity(intent);
            }
        } else if (v.equals(sendRecordLay)) {
            if (!TextUtils.isEmpty(BaseActivity.TOKEN)){
                refreshFlag = true;
                Intent intent = new Intent(getActivity(), RecordActivity.class);
                startActivity(intent);
            } else {
                resumeFlag = true;
                Intent intent = new Intent(getActivity(), LoginActivity.class);
                startActivity(intent);
            }
        } else if (v.equals(myCollectionLay)) {
            if (!TextUtils.isEmpty(BaseActivity.TOKEN)){
                refreshFlag = true;
                Intent intent = new Intent(getActivity(), MyFavoriteActivity.class);
                startActivity(intent);
            } else {
                resumeFlag = true;
                Intent intent = new Intent(getActivity(), LoginActivity.class);
                startActivity(intent);
            }
        } else if (v.equals(inviteLay)) {
            if (!TextUtils.isEmpty(BaseActivity.TOKEN)){
                refreshFlag = true;
                Intent intent = new Intent(getActivity(), InviteActivity.class);
                startActivity(intent);
            } else {
                resumeFlag = true;
                Intent intent = new Intent(getActivity(), LoginActivity.class);
                startActivity(intent);
            }
        } else if (v.equals(editPersonalDetailsLay)) {
            if (!TextUtils.isEmpty(BaseActivity.TOKEN)){
                refreshFlag = true;
                Intent intent = new Intent(getActivity(), EditUserInfoActivity.class);
                startActivity(intent);
            } else {
                resumeFlag = true;
                Intent intent = new Intent(getActivity(), LoginActivity.class);
                startActivity(intent);
            }
      }
    }

    private void logout() {
        ((MainActivity) getActivity()).httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                URL_LOGOUT,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        ((MainActivity) getActivity()).showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("logout : " + responseInfo.result.toString());
                        HashMap<String, Object> map = ((MainActivity) getActivity()).parseSimpleJson(responseInfo.result.toString());

                        if ((int)map.get("code") != 1) {
                            if (((MainActivity) getActivity()).checkLoginState((int) map.get("code"), getActivity())) {
                                Toast.makeText(getActivity(), map.get("error").toString(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            BaseActivity.TOKEN = "";
                            SharedPreferences.Editor editor = BaseActivity.userInfoPreferences.edit();
                            editor.clear();
                            editor.commit();
                            userCenterTitleLay.setEnabled(true);
                            logoutBtn.setVisibility(View.INVISIBLE);
                            userHeadImg.setImageResource(R.drawable.icon_default_head_img);
                            userNameText.setText(R.string.click_to_login);
                            userMailText.setText("");
                        }
                        ((MainActivity) getActivity()).cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(getActivity(), s, Toast.LENGTH_SHORT).show();
                        ((MainActivity) getActivity()).cancelProgressDialog();
                    }
                });
    }
}
