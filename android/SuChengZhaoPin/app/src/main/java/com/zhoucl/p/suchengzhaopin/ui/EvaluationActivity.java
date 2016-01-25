package com.zhoucl.p.suchengzhaopin.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
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
 * Created by zhoucl on 2015/7/29.
 * 自我评价
 */
public class EvaluationActivity extends BaseActivity implements View.OnClickListener {
    private static String URL_EVALUATION = IP + "/app/resume_api/evaluation";//POST resume_id evaluation

    private String resume_id, evaluation;

    @ViewInject(R.id.title_text)
    private TextView titleText;

    @ViewInject(R.id.title_back_btn)
    private ImageButton titleBackBtn;

    @ViewInject(R.id.evaluation_edit)
    private EditText evaluationEdit;

    @ViewInject(R.id.evaluation_save_btn)
    private Button saveBtn;

    private Gson gson;
    private HttpUtilsWithToken httpUtilsWithToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_evaluation);
        ViewUtils.inject(this);

        Bundle bundle = getIntent().getExtras();
        resume_id = bundle.getString("resume_id");
        evaluation = bundle.getString("evaluation");

        gson = new Gson();
        httpUtilsWithToken = new HttpUtilsWithToken();

        init();
    }

    public void init() {
        titleText.setText(R.string.self_assessment);
        evaluationEdit.setText(evaluation);

        titleBackBtn.setOnClickListener(this);
        saveBtn.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.equals(titleBackBtn)) {
            finish();
        } else if (v.equals(saveBtn)) {
            saveEvaluation();
        }
    }

    private void saveEvaluation() {
        RequestParams params = new RequestParams();
        params.addBodyParameter("resume_id", resume_id);
        params.addBodyParameter("evaluation", evaluationEdit.getText().toString());

        httpUtilsWithToken.send(HttpRequest.HttpMethod.POST,
                URL_EVALUATION,
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
                            Toast.makeText(EvaluationActivity.this, map.get("error").toString(), Toast.LENGTH_SHORT).show();
                        } else {
                            finish();
                        }
                        cancelProgressDialog();
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Toast.makeText(EvaluationActivity.this, s, Toast.LENGTH_SHORT).show();
                        cancelProgressDialog();
                    }
                });
    }

}
