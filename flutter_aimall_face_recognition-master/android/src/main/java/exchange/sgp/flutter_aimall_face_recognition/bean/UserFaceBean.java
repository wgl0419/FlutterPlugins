package exchange.sgp.flutter_aimall_face_recognition.bean;

import org.greenrobot.greendao.annotation.Convert;
import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Id;

import org.greenrobot.greendao.annotation.Generated;
import org.greenrobot.greendao.annotation.Index;
import org.greenrobot.greendao.annotation.NotNull;

import java.util.Arrays;

@Entity(nameInDb = "user_face", indexes = {@Index(value = "uid, email, mobile", unique = true)})
public class UserFaceBean {
    @Id(autoincrement = true)
    Long id;

    @NotNull
    private String uid;

    private String email;
    private String mobile;

    @NotNull
    private String faceToken;

    @NotNull
    private byte[] feature;

    @Generated(hash = 366614073)
    public UserFaceBean() {
    }

    @Generated(hash = 1402661281)
    public UserFaceBean(Long id, @NotNull String uid, String email, String mobile,
            @NotNull String faceToken, @NotNull byte[] feature) {
        this.id = id;
        this.uid = uid;
        this.email = email;
        this.mobile = mobile;
        this.faceToken = faceToken;
        this.feature = feature;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public byte[] getFeature() {
        return feature;
    }

    public void setFeature(byte[] feature) {
        this.feature = feature;
    }

    public String getFaceToken() {
        return faceToken;
    }

    public void setFaceToken(String faceToken) {
        this.faceToken = faceToken;
    }

    @Override
    public String toString() {
        return "UserFaceBean{" +
                "id=" + id +
                ", uid='" + uid + '\'' +
                ", email='" + email + '\'' +
                ", mobile='" + mobile + '\'' +
                ", faceToken='" + faceToken + '\'' +
                ", feature=" + Arrays.toString(feature) +
                '}';
    }
}
