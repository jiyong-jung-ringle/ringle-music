# README

Ringle Music에 대한 Toy Project입니다.

## Version

- Ruby: 2.7.2
- Rails: 7.0.4
- mySQL: 8.0.30

## 설치

- 필요한 프로그램들 설치
- bundle install
- rake db:create
- rake db:migrate
- rake db:seed(10명의 User, 10개의 music, 3개의 gruop, 13개의 플레이리스트(10개의 User playlist, 13개의 group playlist), 랜덤 좋아요 추가 가능)

## 요구사항

- 음원 목록 API
  - [x] 조회 API
    - 정렬 방식
      - 정확도순
      - 인기순
      - 최신순
  - [x] 좋아요 API
    - 유저가 음원에 좋아요 누를 수 있음
    - 좋아요 누른 음원 목록을 조회할 수 있어야함. => 이 때 역시 유저 이름을 통한 정확도순, 최신순으로 조회할 수 있어야함.
      - 최신순은 user의 '가입 순서'가 아닌 **'좋아요 누른 순서'**
- 플레이리스트 음원 목록 API
  - [ ] 음원 조회 API
    - 정렬 방식
      - 정확도순
      - 인기순
      - 최신순
  - [ ] 플레이리스트 조회 API
    - 정렬 방식
      - 인기순
      - 최신순
  - [ ] 추가/삭제(목록 상 중복 가능) API
    - 플레이리스트의 소유자만 가능
    - 최대 100개까지 등록 가능
  - [ ] 좋아요 API
    - 유저가 플레이리스트에 좋아요 누를 수 있음
    - 좋아요 누른 플레이리스트 목록을 조회할 수 있어야함.
  - [ ] 플레이리스트 내 음원의 정보 가져오기 API
    - (그룹의 경우) 누가 추가했는지 확인 가능
    - 언제 추가했는지 확인 가능
    - 플레이리스트에서 음원의 중복을 허용하는 만큼, 플레이리스트 내 음원의 삭제 시 identifier로 쓰임
- 그룹 만들기
  - [ ] 그룹 목록, 그룹 만들기, 인원 추가, 그룹 가입, 그룹 나가기 API
  - [ ] 그룹 플레이리스트 추가/삭제(목록 상 중복 가능) API
    - 그룹 멤버만 가능
- 그밖의 서비스를 위해 필요한 API
  - [ ] 유저 관련 API
    - 회원가입
    - 인증(음원 추가/삭제를 위해 필요)

## 모델링

- [x] User
  - Attribute:
    - name(유저명)
  - 여러 Group과 many-to-many 관계
  - Like와 연결되어 있음(자신이 어디에 좋아요 눌렀는지 확인 가능)
  - 한 개의 플레이리스트를 가짐
  - 유저가 만들어질 때 callback을 통해 플리도 하나 만들어줌
- [x] Group
  - Attribute:
    - name(그룹명으로 쓰임)
  - 여러 User와 many-to-many 관계(각 그룹당 멤버의 중복을 허용하지 않음)
  - 한 개의 플레이리스트를 가짐
  - 그룹이 만들어질 때 callback을 통해 플리도 하나 만들어줌
- [x] Music
  - Attribute:
    - song_name
    - artist_name
    - album_name
    - likes_count
  - 여러 playlist와 many-to-many 관계
  - 유저가 좋아요 누를 수 있음, one-to-many 관계
    - 좋아요 갯수는 counter cache를 통해 likes_count에 저장
- [x] Playlist
  - 효율작인 설계를 위해 Group, User와 합쳐서 사용할 수 있지만, playlist의 확장성을 생각했을때(예: 유저가 다양한 개인 플레이리스트를 만들 수 있게될 경우) 따로 있는 것이 유리하다고 생각해서 모델링하였습니다.
  - Attribute:
    - ownable(polymorphic, 소유권자 지정, User 또는 Group)
    - likes_count
    - musics_count
  - ownable을 통해 한개의 User 또는 Gruop과 관계되어 있음
  - 여러 music과 many-to-many 관계
    - 음원 갯수는 counter cache를 통해 musics_count에 저장
  - 유저가 좋아요 누를 수 있음, one-to-many 관계
    - 좋아요 갯수는 counter cache를 통해 likes_count에 저장
  - 최대 100개까지 음원 추가 가능, 넘어가면 오래된것부터 삭제
    - 근데 callback으로 처리하고싶은데 현재 model에서 음원 추가 시 조건문 통해 삭제되는 방식
      - 도움 받을 수 있을까요..
- [x] Like
  - Attribute:
    - likable(polymorphic, 좋아요된 Music 또는 Playlist 지정)
  - 하나의 유저가 하나의 게시물에 좋아요 누를 수 있음
    - 좋아요는 한번만 누를 수 있음

## 구현 순서

### Model

    각각의 model에 create, destroy와 같은 기본적인 함수들 구현

    Group의 경우 유저(들) 추가/삭제, Playlist의 경우 음원(들) 추가/삭제 함수를 구현

    Like는 user에 따라 toggle 가능하도록 함.

### API

    API는 Grape를 활용해 구현하고자 함.

    서버는 로컬에서 구현되어 있는 만큼, http://localhost:3000/api/v1/ ~ 의 형식

        ex) GET http://localhost:3000/api/v1/music?limit=20&filter=exact

- Application Service
  - Virtual_column(추가적인 Attribute를 만들어주는 서비스) -> N+1 되는 것을 피하고자 직접 쿼리문 작성해서 하였는데 좋은 방법인지 모르겠습니다.
    - is_liked(api를 요청한 유저가 특정 Music 또는 playlist에 좋아요를 눌렀는지를 attribute "is_liked"에 추가해줌)
    - get_similarity_score(keyword에 맞게 score를 계산해서 attribute "score"에 추가해줌. ordering 시 사용)
      - 정확도를 구현하기 어려워 MySQL Like를 통해 구현하였는데, 이 역시 좋은 방법인지 모르겠습니다.
  - Feed(음원 목록 검색 서비스)
    - order_filter_status(정렬 status 관리; 최신순:recent, 정확도순:exact, 인기순:popular)
    - ordered_model_getter(정렬된 model을 받아와줌)
      - get_similarity_score를 참고해서 정렬된 model을 return
    - music_getter(음원 목록)
      - ordered_model_getter 및 limit에 맞추어 음원 목록을 json 형식으로 return
      - 음원 목록 조회 API에서 사용됨

-2022.12.27 16:43

# **구현된 API**

1. Music
   - 음원 조회 API -> **GET** /api/v1/music
     - parameters:
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) offset : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 음원 이름, 아티스트 이름, 앨범 이름 한번에 검색 가능
       4. (Optional) filter : 최신순(recent), 인기순(popular), 정확도순(exact)으로 정렬해줌.
     - return
       - total_musics_count: 총 음원의 갯수
       - musics: 음원의 정보를 담는 배열, 음원 id, 음원 이름, 아티스트 이름, 앨범 이름, 좋아요 갯수, Current User가 좋아요하였는지 여부를 담고 있음
   - 좋아요 누르기 API -> **POST** /api/v1/music/{music_id}/like
     - return
       - 성공 여부
   - 좋아요 취소 API -> **DELETE** /api/v1/music/{music_id}/like
     - return
       - 성공 여부
   - 좋아요 누른 유저 리스트 API -> **GET** /api/v1/music/{music_id}/like
     - parameters:
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) offset : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 유저 이름으로 검색 가능
       4. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
          - 최신순은 **좋아요 누른 순서**로 정렬
     - return
       - total_likes_count: 총 좋아요 갯수
       - like_users: 좋아요 누른 유저 정보를 담고 있는 배열. name과 user id가 있음.
