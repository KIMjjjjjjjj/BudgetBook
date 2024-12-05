# **공유 가계부**

## 개요
"공유 가계부" 앱은 수입 및 지출을 체계적으로 기록하고 관리하여 사용자가 재정 상태를 명확히 파악하고, 월별 예산을 설정하여 건강한 재정 상태를 유지하도록 돕는 앱이다. 또한, 공동 생활을 하는 사람들과 함께 재정 계획을 협력적으로 관리할 수 있는 **가계부 공유 기능**을 제공한다.


## 개발 환경
### 1. 개발 환경 및 언어
- **⚡ Flutter**: 앱 개발을 위한 프레임워크
- **💻 Dart**: Flutter의 프로그래밍 언어


### 2. 백엔드 서비스
- **🔥 Firebase**:
  - Firestore: 실시간 데이터베이스
  - Firebase Authentication: 사용자 인증
  - Firebase Cloud Storage: 파일 저장
  - Firebase Messaging: 푸시 알림
  - Firebase AppCheck: 앱 보안 검증


## 주요 기능
1. **사용자 등록 및 로그인**
   - 이메일 인증을 통한 본인 확인
   - 아이디, 비밀번호로 로그인

2. **수입 및 지출 내역 기록**
   - 날짜, 카테고리, 금액, 메모를 통해 수입 및 지출 내역 기록 제공

3. **지출 통계**
   - 일일, 주간, 월간 지출 카테고리별 분석 기능 제공(파이 차트 형태로 시각화)

4. **월별 예산 설정**
   - 예산 설정 기능 제공

5. **알림 기능**
   - 지출 경고 알림, 정기 지출 알림, 공유 초대 알림 등 다양한 알림 기능 제공

6. **가계부 공유 기능**
   - 가족이나 공동 생활을 하는 사람들과 예산을 공유하고 협력적으로 관리

7. **계정 관리**
   - 이메일 및 비밀번호 변경, 계정 삭제 기능 제공


## 프로젝트 구조
### 1. **회원가입/로그인 화면**
- **회원가입**: 사용자 닉네임, 아이디, 비밀번호, 이메일 주소를 입력하여 회원 가입 및 이메일 인증
- **로그인**: 아이디 및 비밀번호를 입력하여 로그인
- **아이디 찾기**: 이메일을 통한 본인 인증 후 아이디 찾기
- **비밀번호 찾기**: 이메일을 통한 본인 인증 후 비밀번호 재설정
<img src="https://github.com/user-attachments/assets/c529d6cb-3dd0-4ed5-9d93-ca528dcb7ddd" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/3e5b4adf-2f2d-4276-b04a-ed726f4102e1" width="30%" height="40%">

### 2. **방 선택 화면**
- **공유방 개설**: 공유방 이름을 설정하고, 아이디로 사용자를 검색하여 방에 초대
<img src="https://github.com/user-attachments/assets/82dca17c-e143-449a-a16a-1f55f96d3d86" width="30%" height="40%">

### 3. **수입 및 지출 내역 화면**
- **수입 및 지출 내역 조회**: 카테고리, 메모, 금액을 확인할 수 있으며, 이번 달 수입과 지출 총액을 확인
- **수입 및 지출 내역 작성**: 날짜, 카테고리, 금액, 메모를 통해 수입 및 지출 내역 기록
<img src="https://github.com/user-attachments/assets/bce41a90-fbad-4895-b5a6-d19d93bef8e1" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/030647de-a8df-44fa-ba66-d1dd6b8b7e08" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/4d6e1fad-f2c3-4a85-a0d6-9829fd58009f" width="30%" height="40%">

### 4. **파이 차트 화면**
- **카테고리별 분석**: 기간별로 지출 카테고리 분석 그래프(파이 차트) 제공
<img src="https://github.com/user-attachments/assets/29f0583a-6414-42fd-8027-93d23dd1b14b" width="30%" height="40%">

### 5. **예산 설정 화면**
- **월별 예산 설정**: 방마다 월별 예산을 설정하고 관리
<img src="https://github.com/user-attachments/assets/61861239-9798-4870-b7d2-9f59a77bcdfc" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/2b1c5bd1-4f5e-41cc-8918-d44d53a75239" width="30%" height="40%">

### 6. **설정 화면**
- **계정 관리**: 이메일, 비밀번호 변경 및 계정 삭제 기능 제공
- **프로필 편집**: 프로필 사진 변경과 닉네임 재설정 기능 제공
- **공유 설정**: 공유방 이름 수정 및 아이디를 통한 유저 초대 기능 제공
- **알림 설정**: 알림 기능 설정(지출 경고 알림, 정기 지출 알림, 초대 알림 등)
<img src="https://github.com/user-attachments/assets/08a83f21-bd79-4f47-b386-e051f902bf98" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/e04c4e04-614f-4b00-9dcf-42e4594dd77f" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/bdc88b8e-dd09-4767-b0a1-76e6a63d5be5" width="30%" height="40%">
<img src="https://github.com/user-attachments/assets/242a0c67-6f56-4ba8-87a6-1997fb91efd8" width="30%" height="40%">

## 기대 효과
- **소비 습관 개선:** 카테고리별 지출 분석 기능으로 불필요한 소비 줄이고 필요한 항목에 예산을 효율적으로 할당
- **재정 관리 협력 강화:** 가계부 공유 기능을 통해 공동 생활을 하는 사람들과 재정 계획을 협력적으로 관리
- **재정 안정성 확보:** 장기적인 재정 목표 달성에 기여

  

  

  

