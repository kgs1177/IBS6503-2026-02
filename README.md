# 컴퓨터유전체학특론 (IBS6503) 2026-2

인하대학교 생명과학과, 한성규

실습 데이터와 실습 노트북을 담은 저장소입니다. 강의 자료는 I-Class에 올립니다.

주교재: [Vibe Bioinformatics](https://chaek.org/books/vibe-bioinformatics)

---

## 시작하기

1. 이 페이지 오른쪽 위 **Fork** 버튼으로 내 GitHub 계정에 복사합니다
2. Qoka 대화 입력창에 입력합니다

   > github.com/내 아이디/IBS6503-2026-02 저장소를 문서 폴더에 clone해줘.

3. Qoka의 프로젝트 열기에서 clone한 `IBS6503-2026-02` 폴더를 엽니다

새 자료가 올라오면 내 fork 페이지에서 **Sync fork**를 누른 뒤, Qoka 대화 입력창에 입력합니다.

> GitHub에서 최신 상태를 받아와줘.

---

## 폴더 구조

```
IBS6503-2026-02/
├── data/          실습 데이터. 고치지 않는다
├── course/labs/   주차별 실습 노트북 원본. 고치지 않는다
├── analysis/      내 코드와 노트북
└── results/       내 실행 결과
```

실습 노트북은 `analysis/weekN/`으로 복사해서 씁니다. `data/`와 `course/`의 파일을 고치지 않으면 새 자료를 받아올 때 부딪히지 않습니다.

---

## 실습 데이터

| 파일 | 내용 |
|---|---|
| `data/airway_scaledcounts.subset.tsv` | 사람 기도 평활근 세포 RNA-seq 카운트. 유전자 38,694개, 샘플 4개 |

출처: Himes BE, et al. *RNA-Seq transcriptome profiling identifies CRISPLD2 as a glucocorticoid responsive gene that modulates cytokine function in airway smooth muscle cells.* PLoS One 9(6):e99625 (2014). PMID 24926665

대조군과 덱사메타손 처리군을 짝지은 실험입니다. 원 실험은 세포주 4쌍이고 이 파일은 그중 2쌍입니다.

> 이 파일은 소수점을 쉼표로 표기합니다(`723,0` = 723.0). 읽을 때 옵션을 지정해야 합니다.

---

## 주차별 실습

| 주차 | 주제 | 노트북 |
|---|---|---|
| 3 | 표를 코드로 읽기 | `course/labs/week3/week3_reading.ipynb` |
