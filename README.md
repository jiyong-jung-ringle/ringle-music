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
- rake db:seed(100명의 User(지금은 300명), 1500개의 music(지금은 1,001,698개), 30개의 group, 130개의 플레이리스트(100개의 User playlist, 30개의 group playlist, 지금은 330개), 랜덤 좋아요 추가 가능)
- pem 파일은 테스팅을 위해 ignore하지 않았습니다.
- JWT는 RS256 방식을 사용하며, ssl 인증서를 key로 사용합니다.

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
  - [x] 음원 조회 API
    - 정렬 방식
      - 정확도순
      - 인기순
      - 최신순
      - (그룹의 경우) 누가 추가했는지 확인 가능
      - 언제 추가했는지 확인 가능
      - 플레이리스트에서 음원의 중복을 허용하는 만큼, 플레이리스트 내 음원의 삭제 시 identifier로 쓰임
  - [x] 플레이리스트 조회 API
    - 정렬 방식
      - 인기순
      - 최신순
  - [x] 추가/삭제(목록 상 중복 가능) API
    - 플레이리스트의 소유자만 가능(개인 또는 그룹)
    - 최대 100개까지 등록 가능
  - [x] 좋아요 API
    - 유저가 플레이리스트에 좋아요 누를 수 있음
    - 좋아요 누른 플레이리스트 목록을 조회할 수 있어야함.
- 그룹 만들기
  - [x] 그룹 목록, 그룹명 변경, 그룹 만들기, 인원 추가, 그룹 가입, 그룹 나가기 API
  - [x] 그룹 플레이리스트 추가/삭제(목록 상 중복 가능) API -> 플레이리스트 API와 동일하게 구현되어 있음
    - 그룹 멤버만 가능
- 그밖의 서비스를 위해 필요한 API
  - [x] 유저 관련 API
    - 회원가입
    - 인증(음원 추가/삭제를 위해 필요)

## 모델링

![diagram](./diagram.png)

- [x] User
  - Attribute:
    - name(유저명), password_digest(bcrypt 방식으로 암호화), email(로그인 시 사용)
    - 비밀번호는 DB에서 저장되지 않도록 함.
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
  - 효율적인 설계를 위해 Group, User와 합쳐서 사용할 수 있지만, playlist의 확장성을 생각했을때(예: 유저가 다양한 개인 플레이리스트를 만들 수 있게될 경우) 따로 있는 것이 유리하다고 생각해서 모델링하였습니다.
  - Attribute:
    - ownable(polymorphic, 소유권자 지정, User 또는 Group)
    - likes_count
    - musics_count
  - ownable을 통해 한개의 User 또는 group과 관계되어 있음
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
  - Virtual_column(추가적인 Attribute를 만들어주는 서비스) -> ~~N+1 되는 것을 피하고자 직접 쿼리문 작성해서 하였는데 좋은 방법인지 모르겠습니다.~~  **ids를 통해 어느정도 쿼리문을 피하는 방향으로 해결**
    - ~~is_liked(api를 요청한 유저가 특정 Music 또는 playlist에 좋아요를 눌렀는지를 attribute "is_liked"에 추가해줌)~~
      - user_likes 서비스로 대체 : sql를 생으로 사용하는 것은 다양한 기능 추가에 따른 확장성에 있어 문제될 수 있을 것이라 생각. 
      - is_liked 및 is_joined가 grape entity, 즉 output 딴에서 자동으로 입력될 수 있도록 하고자 할 때 user_likes 및 user_groups를 사용하는 것이 낫다고 판단했습니다.
    - ~~is_joined(api를 요청한 유저가 특정 group에 가입되어 있는지를 attribute "is_joined"에 추가해줌)~~
      - user_groups 서비스로 대체 : 위와 동일한 이슈
    - get_similarity_score(keyword에 맞게 score를 계산해서 attribute "score"에 추가해줌. ordering 시 사용)
      - 정확도를 구현하기 어려워 MySQL Like + SOUNDS LIKE를 통해 구현하였는데, 이 역시 좋은 방법인지 모르겠습니다.
        - 대체방안
          - searchkick : gem을 활용해서 구현해보았으나 너무 불필요한 기능이 많고, 무거워서 소규모에서는 오히려 like보다 느렸음. 불필요하다 생각해서 다시 지움
          - MATCH AGAINST : 구현해보았으나 유사도 검색을 지원하지 않아 다시 지움. => **근데 음원이 100만건 되니까 정말 빠르다고 느낌**
        - 구현 방식:
          - 어떤 column에 대해 검색 시
            - select 문을 통해 sounds like, like를 통해 정확도 score를 계산하고, score가 높은 순으로 정렬
          - ex) 유저에서 '철수'를 검색했을 때

      ``` SELECT `users`.*, (LOWER(`users`.`name`) SOUNDS LIKE LOWER(`철수`)) / 4 + ((LOWER(`users`.`name`) LIKE LOWER(CONCAT('%', `철수`, '%'))) + (LOWER(`철수`) LIKE LOWER(CONCAT(`%`, `users`.`name`, `%`))) + (LOWER(name) LIKE LOWER(`철수`))) * 3 / 4 as `score` FROM `users` ORDER BY `score` DESC ```
        
        => 추가(22.01.10)
        
          음원을 많이 추가한 경우 LIKE를 통한 sort는 약 7~10초가 걸림. Music list에 대해서만 **searchkick** gem을 활용하여 sorting할 수 있도록 함.
        
          => WHERE LIKE 구절을 사용하는 경우 '정확도순 검색'이 안되기 때문

          음원을 제외한 나머지는 기존 방식대로 score에 따라 sort (로컬에서 500ms 이내로 결과 받음)


    - Feed Service(Feed 목록 검색 서비스)
      - order_filter_status(정렬 status 관리; 최신순:recent, 정확도순:exact, 인기순:popular)
      - ordered_model_getter(정렬된 model을 받아와줌)
        - get_similarity_score를 참고해서 정렬된 model을 return
      - musics_getter(음원 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 음원 목록을 json 형식으로 return
        - 음원 목록 조회 API에서 사용됨
      - likes_getter(좋아요한 유저 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 특정 음원/플리에 좋아요한 유저들의 목록을 json 형식으로 return
      - playlists_getter(플리 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 플리 목록을 json 형식으로 return
      - playlist_musics_getter(플리 내 음원 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 특정 플리 내 음원 목록을 json 형식으로 return
      - groups_getter(그룹 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 그룹 목록을 json 형식으로 return
      - group_users_getter(그룹 내 유저 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 그룹 내 유저 목록을 json 형식으로 return
      - users_getter(유저 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 유저 목록을 json 형식으로 return
      - like_musics_getter(좋아요한 음원 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 특정 유저가 좋아요한 음원 목록을 json 형식으로 return
      - like_playlists_getter(좋아요한 음원 목록)
        - ordered_model_getter 및 page_number, limit에 맞추어 특정 유저가 좋아요한 플리 목록을 json 형식으로 return
    - Like Service(좋아요 서비스)
      - create_like
        - 좋아요 등록 기능 수행
      - delete_like
        - 좋아요 삭제 기능 수행
    - Playlist Service(플레이리스트 서비스)
      - add_music
        - playlist 내 음원 추가 기능 수행
      - delete_music
        - playlist 내 음원 삭제 기능 수행
    - Group Service(그룹 서비스)
      - create_group
        - 그룹 생성 기능 수행
      - join_group
        - 그룹 가입 기능 수행
      - exit_group
        - 그룹 탈퇴 기능 수행
    - Auth Service(인증 서비스)
      - jwt_creator
        - 유저의 정보를 담는 jwt 생성
      - jwt_encoder/decoder
      - jwt_validator
        - jwt를 통해 user 정보 불러오기
    - User Service(유저 서비스)
      - user_groups
        - 유저가 속한 그룹의 id 리스트 반환
      - user_likes
        - 유저가 속한 likes의 id 리스트 반환
      - change_name
        - 유저 이름 변경
      - change_password
        - 유저 패스워드 변경
      - get_info
        - 특정 유저 정보 불러오기
      - signin
        - 이메일/비밀번호를 통해 올바른 유저 정보 및 jwt 불러오기
      - signup
        - 이메일/비밀번호를 통해 유저 생성
    - Auth Service(인증 서비스)
      - jwt_creator
        - 유저 정보를 토대로 jwt 생성
      - jwt_encoder/decoder
      - jwt_validator
        - jwt를 통해 user 정보 불러오기

### Grape Entity
 - response는 Grape Entity를 활용하여 추후에 다른 코드를 작성하였을 때에도 동일한 양식으로 return될 수 있도록 하였습니다.
 - 기본적으로 모든 API response는 default entity를 통합니다. default entity는 아래의 형식을 따릅니다.
    
    ```{success: true, data:{...}}```
 - User, Music, Group, playlist에 대해 각각 entity가 있으며, Music 및 playlist에는 response에 유저가 좋아요를 눌렀는지에 대한 정보를 **알아서** 붙여주고, Group에는 response에 유저가 이 그룹에 가입되어있는지에 대한 정보를 **알아서** 붙여줍니다. 
   - N+1 쿼리를 방지하고자 user_likes, user_groups service를 활용합니다.
 - 각각의 entity는 조건에 맞게 return이 조금씩 다를 수 있습니다. 

# **구현된 API**

2023.1.9일 기준

1. Music

   - 음원 조회 API -> **GET** /api/v1/musics
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 음원 이름, 아티스트 이름, 앨범 이름 한번에 검색 가능
       4. (Optional) filter : 최신순(recent), 인기순(popular), 정확도순(exact)으로 정렬해줌.
     - return
       - total_musics_count: 총 음원의 갯수
       - musics: 음원의 정보를 담는 배열, 음원 id, 음원 이름, 아티스트 이름, 앨범 이름, 좋아요 갯수, Current User가 좋아요하였는지 여부를 담고 있음
     - error
       - 에러를 리턴하지 않음
   - 좋아요 누르기 API -> **POST** /api/v1/musics/**{music_id}**/likes
     - return
       - 성공 여부
     - error
       - Music does not exist: {music_id}가 잘못된 경우
       - Already liked: 이미 좋아요를 누른 경우
   - 좋아요 취소 API -> **DELETE** /api/v1/musics/**{music_id}**/likes
     - return
       - 성공 여부
     - error
       - Music does not exist: {music_id}가 잘못된 경우
       - Already unliked: 이미 좋아요를 누르지 않은 경우
   - 좋아요 누른 유저 리스트 API -> **GET** /api/v1/musics/**{music_id}**/likes
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 유저 이름으로 검색 가능
       4. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
       - 최신순은 **좋아요 누른 순서**로 정렬
     - return
       - total_likes_count: 총 좋아요 갯수
       - like_users: 좋아요 누른 유저 정보를 담고 있는 배열. name과 user_id가 있음.
     - error
       - Music does not exist: {music_id}가 잘못된 경우

2. Playlist
   - 플리 리스트 조회 API -> **GET** /api/v1/playlists
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) filter : 최신순(recent), 인기순(popular)으로 정렬해줌.
     - return
       - total_playlists_count: 총 음원의 갯수
       - playlists: 플리의 정보를 담는 배열, 플리 id, 좋아요 갯수, 소유권자 타입(유저/그룹) 및 소유 유저/그룹의 정보, Current User가 좋아요하였는지 여부를 포함.
     - error
       - 에러를 리턴하지 않음
   - 좋아요 누르기 API -> **POST** /api/v1/playlists/**{playlist_id}**/likes
     - return
       - 성공 여부
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
       - Already liked: 이미 좋아요를 누른 경우
   - 좋아요 취소 API -> **DELETE** /api/v1/playlists/**{playlist_id}**/likes
     - return
       - 성공 여부
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
       - Already liked: 이미 좋아요를 누른 경우
   - 좋아요 누른 유저 리스트 API -> **GET** /api/v1/playlists/**{playlist_id}**/likes
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 유저 이름으로 검색 가능
       4. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
       - 최신순은 **좋아요 누른 순서**로 정렬
     - return
       - total_likes_count: 총 좋아요 갯수
       - like_users: 좋아요 누른 유저 정보를 담고 있는 배열. name과 user_id가 있음.
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
   - 플리 내 음원 조회 API -> **GET** /api/v1/playlists/**{playlist_id}**
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 음원 이름, 아티스트 이름, 앨범 이름 한번에 검색 가능
       4. (Optional) filter : 최신순(recent), 인기순(popular), 정확도순(exact)으로 정렬해줌.
     - return
       - total_musics_count: 플리 내 총 음원의 갯수
       - musics: 음원의 정보를 담는 배열, 음원 id, 음원 이름, 아티스트 이름, 앨범 이름, 좋아요 갯수, Current User가 좋아요하였는지, **누가 음원을 추가했는지** 여부를 담고 있음
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
   - 플리 내 음원 추가 API -> **POST** /api/v1/playlists/**{playlist_id}**
     - parameters
       1. (Require) music_ids : 추가할 음원의 id 배열
     - return
       - success: 보낸 music_ids에 대한 추가 결과를 boolean으로 표시한 object
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
       - You cannot modify this playlist: 이 플리에 대한 소유권이 없는 경우(group 플리, 개인 플리)
       - Cannot add musics: parameter로 받은 음악이 **한개도** 존재하지 않는 경우
   - 플리 내 음원 삭제 API -> **DELETE** /api/v1/playlist/**{playlist_id}**
     - parameters
       1. (Require) music_ids : 삭제할 음원의 **플리 내 music id 배열**
     - return
       - success: 보낸 music_ids에 대한 삭제 결과를 boolean으로 표시한 object
     - error
       - Playlist does not exist: {playlist_id}가 잘못된 경우
       - You cannot modify this playlist: 이 플리에 대한 소유권이 없는 경우(group 플리, 개인 플리)
       - Cannot delete musics: parameter로 받은 음악이 **한개도** 존재하지 않는 경우
3. Group
   - 그룹 리스트 조회 API -> **GET** /api/v1/groups
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 이름 검색 키워드
       4. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
     - return
       - total_groups_count: 총 그룹의 갯수
       - groups: 그룹의 정보를 담는 배열. 그룹 id, 이름, 가입된 유저 수, Current User의 그룹 가입 여부를 담고 있음
     - error
       - 에러를 리턴하지 않음
   - 그룹 내 유저 조회 API -> **GET** /api/v1/groups/**{group_id}**/users
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 이름 검색 키워드
       4. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
     - return
       - total_users_count: 총 그룹 내 유저의 갯수
       - users: 유저의 정보를 담는 배열. 유저 id, 이름, 가입 날짜를 담고 있음
     - error
       - Group does not exist: {group_id}가 잘못된 경우
   - 그룹 가입 API -> **PUT** /api/v1/groups/**{group_id}**
     - return
       - success: true
     - error
       - Group does not exist: {group_id}가 잘못된 경우
       - Already joined: 이미 가입되어 있는 경우
   - 그룹명 변경 API -> **PATCH** /api/v1/groups/**{group_id}**
     - parameters
     1. (Require) name : 바꿀 그룹 이름
     - return
       - success: true
     - error
       - Group does not exist: {group_id}가 잘못된 경우
       - Cannot modify group name: 그룹에 속해있지 않은 경우
   - 그룹 탈퇴 API -> **DELETE** /api/v1/groups/**{group_id}**
     - return
       - success: true
     - error
       - Group does not exist: {group_id}가 잘못된 경우
       - Not joined this group: 이 그룹에 가입되어 있지 않은 경우
   - 그룹 만들기 API -> **POST** /api/v1/groups
     - parameters
       1. (Require) name : 그룹 이름
       2. (Optional) user_ids: 유저 아이디 배열
     - return
       - {만들어진 group id, playlist_id, 성공 유저들}
     - error
       - cannot make group: 그룹이 될 유저 아이디가 모두 이상해서 그룹을 만들 수 없는 경우
         - current_user의 경우 user_ids에 없어도 만들어지는 그룹에 자동 가입됨.
4. User
   - 현재 유저 정보 조회 API -> **GET** /api/v1/users/info
     - return
       - users: 현재 유저 정보(id, name, created_at)
     - error
       - 에러를 리턴하지 않음
   - 현재 유저 이름 변경 API -> **PATCH** /api/v1/users/info/name
     - parameters
       1. (Require) name : 바꿀 유저 이름
       2. (Require) password : 유저의 패스워드(확인용)
     - return
       - success: true
     - error
       - Unauthorized : 패스워드가 틀릴 때
   - 현재 유저 비밀번호 변경 API -> **PATCH** /api/v1/users/info/password
     - parameters
       1. (Require) new_password : 바꿀 패스워드
       2. (Require) old_password : 유저의 패스워드(확인용)
     - return
       - success: true
     - error
       - Unauthorized : 패스워드가 틀릴 때
   - 현재 유저가 좋아요한 음원 리스트 API -> **GET** /api/v1/users/likes/musics
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) keyword : 검색 키워드. 음원 이름, 아티스트 이름, 앨범 이름 한번에 검색 가능
       4. (Optional) filter : 최신순(recent), 인기순(popular), 정확도순(exact)으로 정렬해줌.
          - 최신순은 좋아요 누른 순서
     - return
       - total_musics_count: 총 음원의 갯수
       - musics: 음원의 정보를 담는 배열, 음원 id, 음원 이름, 아티스트 이름, 앨범 이름, 좋아요 갯수, 좋아요한 시간
     - error
       - 에러를 리턴하지 않음
   - 현재 유저가 좋아요한 플리 리스트 API -> **GET** /api/v1/users/likes/playlists
     - parameters
       1. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       2. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       3. (Optional) filter : 최신순(recent), 인기순(popular)으로 정렬해줌.
          - 최신순은 좋아요 누른 순서
     - return
       - total_playlists_count: 총 플리의 갯수
       - playlists: 플리의 정보를 담은 배열, likes_count, 언제 좋아요하였는지, 플리 id, 플리 소유권자(유저/그룹)
     - error
       - 에러를 리턴하지 않음
   - 유저 리스트 API -> **GET** /api/v1/users
     - parameters
       4. (Optional) limit : Pagination에 사용. 최대 표시할 갯수, 기본값은 50
       5. (Optional) page_number : Pagination에 사용. 0부터 시작, 기본값은 0
       6. (Optional) keyword : 검색 키워드. 유저 이름으로 검색 가능
       7. (Optional) filter : 최신순(recent), 정확도순(exact)으로 정렬해줌.
     - return
       - total_users_count: 총 유저 갯수
       - users: 유저들의 정보. id, name, created_at
     - error
       - 에러를 리턴하지 않음
   - 회원가입 API -> **GET** /api/v1/users/signup
     - parameters
       8. (Require) email : 사용할 이메일 주소
       9. (Require) name : 사용할 이름
       10. (Require) password : 사용할 비밀번호
     - return
       - jwt
       - user: 가입된 유저의 정보
     - error
       - Already signed. Please logout : 이미 로그인되어 있는 경우
       - Please use different Email address : 이미 사용중인 이메일인 경우
   - 로그인 API -> **GET** /api/v1/users/signin
     - parameters
       11. (Require) email : 이메일 주소
       12. (Require) password : 비밀번호
     - return
       - jwt
       - user: 유저의 정보
     - error
       - Already signed. Please logout : 이미 로그인되어 있는 경우
       - Login Failed : 이메일/비밀번호가 틀린 경우

# Exception Handling
* 모든 에러 케이스에 대해 success를 false로 return
* development 환경이 아닌 경우에 대해 소스코드가 노출되는 일 없도록 Internel server error 사용
* SQL injection을 방지하고자 검색 기능에 대해 sanitized string 사용

# Concurrency Issue
* Model 레벨에서 Concurrency를 해결할 수 있음을 가정할 수 있도록 Model level에서 concurrcency를 보장하고자 하였습니다.
* 개인 유저의 설정은 고려하지 않고, group, playlist와 같이 다양한 유저가 접근할 수 있는 리소스에 대해 lock을 활용해 concurrency problem을 방지하고자 함.


# Todo
* '정확도순 검색' : 현재는 searchkick과 LIKE scoring을 통해 구현한 상태인데, 22.01.10 오후에 찾은 것이라 아직 불완전. 
* Concurrcency Test : Multithread를 활용해 concurrency issue가 있는지 확인할 수 있는 test case를 제작하려 하였음. 10개의 thread를 활용해 test하고자 하였는데 ruby의 multithreading이 익숙하지 않아서 결국 완성하지 못함. 
* General Test Case : 코드가 확장되는만큼 작동하던 기능이 작동하지 않게 되는 경우가 있는데 기본적인 테케를 만들 수 있으면 좋을 듯.
* 프로덕션에서 필요하다고 생각하는 기능들인 어드민 기능, 유저 삭제 등과 같은 기능이 구현되어 있지 않음.
* 아직은 부족한 Concurrency Issue
  * 테스트의 부족으로 다양한 유저의 동시 접근 시 정상작동하는지 확인하지 못함
  * Update뿐만 아니라 db를 읽는 과정에서도 concurrency issue는 발생할 수 있다고 생각. 
  * 많은 유저가 이 프로덕션을 사용한다면 꼭 고쳐져야 할 부분
* jwt를 사용하는데 jwt에 대해 아직 완전히 이해하지 못해서 보안이 의심됨.
* 그 외 많은 것들...