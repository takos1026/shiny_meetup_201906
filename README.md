더 나은 주거지역을 찾기 위한 shiny 앱
================

우리는 살면서 여러가지 이유로 주거하는 지역을 옮겨야하고 그때마다 복잡한 의사결정 과정을 거칩니다. 지금 살고 있는 지역에
만족했다면 지금과 같은 생활을 할 수 있을지, 반대로 지금보다 나은 생활이 가능할지. 옮겨갈 지역의 전철역은 지금
내가 주로 이용하는 전철역과 얼마나 다른 모습일까요? 또 비싼만큼 내 생활은 편해질 수 있을까요? 장기적인 관점이 아니라 이사
후 당장 맞닥뜨릴 생활에 대해 가늠해볼 필요가 있습니다. 물론 중요한건 돈이겠지만요.

**주거지역을 이동할 때의 행동 흐름**

0.  동기부여(독립, 결혼, 직장, 자녀교육, 투자, 은퇴, 계약만료, 건강상 이유)
1.  동기에 부합하는 후보지역 탐색
2.  후보지 주소의 근거리 생활권 탐색
3.  최종선정

1)후보지역 탐색에 사용하기 위해 수도권 전철역 군집화하고 2)근거리 생활권 탐색을 위해
[소상공인진흥공단](https://www.semas.or.kr/web/main/index.kmdc)에서
제공하는 상가상권정보에서 관심지역 주변 생활점포를 수집하여 지도에 시각화하였습니다.

#### 데이터

1.  [지하철역
    리스트](http://data.seoul.go.kr/dataList/datasetView.do?infId=OA-12914&srvType=S&serviceKind=1&currentPageNo=1)
2.  [관심 주소, 지하철역 위치와 주변
    상점](https://developers.kakao.com/docs/restapi/local)
3.  [관심 주소 반경 상점](https://www.data.go.kr/dataset/15012005/openapi.do)

#### 주변 속성을 통해 비슷한 활성도를 가지는 전철역끼리 군집화 하기

  - 활성도 산정에 반영하는 속성: 환승라인, 음식점, 카페, 문화시설, 대형마트
  - 반경 200미터이내 역이 존재할 경우 환승라인으로 인지
  - 카카오맵에서 해당 역 + 음식점, 카페, 문화시설, 대형마트 카테고리를 검색했을 때 기본 반경 500m 이내 검색 건수를
    특성의 값으로 하되 환승역은 범위를 추가노선수 당 100m 씩 확장하여 검색
  - 위경도 좌표 + 속성을 변수로 kmeans 클러스터링

**1. 전체 노선 클러스터 분포
확인**

![clustering1](https://drive.google.com/uc?id=1XKXdEOOC2-fy-msKNMMaGfwVNbKFL5_r)

**2. 관심 노선의 클러스터 분포
확인**

![clustering2](https://drive.google.com/uc?id=1Hng3Yjt6R_f882u5fQqUoV4t2HXZdj-4)

**3. 전체 노선에서 관심 클러스터 분포
확인**

![clustering3](https://drive.google.com/uc?id=1A5-FW9k2FxgpxmVOrO5yYmcPv1YtpCAL)

#### 현재 주소지와 후보 주소지 반경 1km 생활 점포 탐색하기

  - 일상생활에서 필요한 업종(병원, 어린이집, 식당, 편의점, 유흥주점, 카페, 미용실, 동물병원)의 분포로 주생활권 파악
    가능
  - 활용:
   1) 빛, 소음 공해에서 자유로울 수 있도록 식당, 유흥주점 밀집구역을 피해 거주지를 정한다.
   2) 손님이 지금 살고 있는 지역의 현황을 보고 비슷한 위치특성을 가진 집을 보여준다. -공인중개사
   3) 전철역 바로 앞에서 친구를 만날수 있는지 알아본다.

**1. 주소를 중심으로 주생활권 확인**
![comparison1](https://drive.google.com/uc?id=14-q30qfNXAdEc6XAfiGFG6Aip_YkcbgP)

**2. 점포업종별 필터 적용하여 관심 업종의 분포 확인**
![comparison2](https://drive.google.com/uc?id=1-XBTF0F4PZSl6pUyWzgHpJLS4OmMzZPa)

<https://takos1026.shinyapps.io/search_new_site>
