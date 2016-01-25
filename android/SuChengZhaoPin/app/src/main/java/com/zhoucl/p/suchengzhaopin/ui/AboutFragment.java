package com.zhoucl.p.suchengzhaopin.ui;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
import com.lidroid.xutils.http.ResponseInfo;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.lidroid.xutils.view.annotation.ViewInject;
import com.umeng.fb.FeedbackAgent;
import com.umeng.fb.SyncListener;
import com.umeng.fb.model.Conversation;
import com.umeng.fb.model.Reply;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.About;

import java.lang.reflect.Type;
import java.util.List;

/**
 * Created by zhoucl on 2015/6/29.
 */
public class AboutFragment extends Fragment implements RadioGroup.OnCheckedChangeListener, View.OnClickListener {

    private static String URL_ABOUT = BaseActivity.IP + "/app/api/about";//GET

    @ViewInject(R.id.title_back_btn)
    private ImageButton backBtn;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.top_tab)
    private RadioGroup topTab;

    @ViewInject(R.id.about_tab)
    private RadioButton aboutTab;

    @ViewInject(R.id.feedback_tab)
    private RadioButton feedbackTab;

    @ViewInject(R.id.about_lay)
    private LinearLayout aboutLay;

    @ViewInject(R.id.feedback_lay)
    private LinearLayout feedbackLay;

    @ViewInject(R.id.about_text)
    private TextView aboutText;

    @ViewInject(R.id.service_tel_text)
    private TextView serviceTelText;

    @ViewInject(R.id.service_qq_text)
    private TextView serviceQQText;

    @ViewInject(R.id.feedback_edit)
    private EditText feedbackEdit;

    @ViewInject(R.id.fb_send_btn)
    private Button fbSendBtn;

    private Gson gson;
    private About about;
    private Conversation mConversation;

    private View rootView;//缓存Fragment view

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            setTab(getResources().getColor(R.color.white),
                    getResources().getColor(R.color.text_default),
                    View.VISIBLE,
                    View.GONE);
        }
    };

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (rootView == null) {
            rootView = inflater.inflate(R.layout.fragment_about, null);
            //****************************初始化******************************
            gson = new Gson();
            mConversation = new FeedbackAgent(getActivity()).getDefaultConversation();
            ViewUtils.inject(this, rootView); //注入view和事件

            titleText.setText(R.string.about_us);
            backBtn.setVisibility(View.GONE);

            topTab.setOnCheckedChangeListener(this);
            fbSendBtn.setOnClickListener(this);
            getAbout();
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
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        switch (checkedId) {
            case R.id.about_tab:
                InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm.isActive(feedbackEdit)) {
                    imm.hideSoftInputFromWindow(getActivity().getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                    handler.sendEmptyMessageDelayed(0, 100);
                } else {
                    setTab(getResources().getColor(R.color.white),
                            getResources().getColor(R.color.text_default),
                            View.VISIBLE,
                            View.GONE);
                }
                titleText.setText(R.string.about_us);
                break;
            case R.id.feedback_tab:
                setTab(getResources().getColor(R.color.text_default),
                        getResources().getColor(R.color.white),
                        View.GONE,
                        View.VISIBLE);
                titleText.setText(R.string.feedback);
                break;
            default:
                break;
        }
    }

    private void setTab(int leftColor, int rightColor, int leftVis, int rightVis) {
        aboutTab.setTextColor(leftColor);
        feedbackTab.setTextColor(rightColor);
        aboutLay.setVisibility(leftVis);
        feedbackLay.setVisibility(rightVis);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(fbSendBtn)) {
            String content = feedbackEdit.getText().toString();
            feedbackEdit.getEditableText().clear();
            if (!TextUtils.isEmpty(content)) {
                // 将内容添加到会话列表
                mConversation.addUserReply(content);
                // 数据同步
                mConversation.sync(new SyncListener() {
                    @Override
                    public void onReceiveDevReply(List<Reply> list) {
                    }

                    @Override
                    public void onSendUserReply(List<Reply> list) {
                        if (list.size() > 0) {
                            if (list.get(0).status.equals(Reply.STATUS_SENT)) {
                                Toast.makeText(getActivity(), R.string.tks_for_your_fb, Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                });
            }
        }
    }

    private void getAbout() {
        ((MainActivity) getActivity()).httpUtilsWithToken.send(HttpRequest.HttpMethod.GET,
                URL_ABOUT,
                new RequestCallBack<Object>() {

                    @Override
                    public void onStart() {
                        ((MainActivity) getActivity()).showProgressDialog();
                    }

                    @Override
                    public void onSuccess(ResponseInfo<Object> responseInfo) {
                        LogUtils.d("getAbout : " + responseInfo.result.toString());
                        Type type = new TypeToken<About>() {
                        }.getType();
                        about = gson.fromJson(responseInfo.result.toString(), type);
                        if (about.getCode() != 1) {
                            if (((MainActivity) getActivity()).checkLoginState(about.getCode(), getActivity())) {
                                Toast.makeText(getActivity(), about.getError(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            aboutText.setText(about.getData().getIntroduction());
                            serviceTelText.setText(about.getData().getPhone());
                            serviceQQText.setText(about.getData().getQq());
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
