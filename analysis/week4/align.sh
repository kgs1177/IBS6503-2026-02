#!/usr/bin/env bash
#
# 4주차 실습: 네 샘플의 paired-end FASTQ 를 hg19 chr1 부분 참조에 hisat2 로 정렬하고
#             좌표순으로 정렬(sort)한 BAM 과 그 인덱스를 만든다.
#
# 입력  data/week4/{1,2}_{control,treated}.R{1,2}.fastq.gz   63 bp paired-end
#       data/week4/hg19_chr1_11.4Mb.fa.gz                    hg19 chr1 앞 11.4 Mb
# 출력  results/week4/<sample>.sorted.bam  (+ .bam.bai)
#       results/week4/<sample>.hisat2.summary.txt
#       results/week4/hisat2_index/hg19_chr1.*.ht2
#
# 실행  저장소 루트에서:  bash analysis/week4/align.sh
#
# 참조 서열은 앞 11,000,000 bp 가 N 이라 정렬 좌표가 그대로 실제 hg19 좌표가 된다.
# 그래서 결과 BAM 을 IGV 의 hg19 유전체에 바로 얹을 수 있다.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
W4="$REPO/data/week4"
OUT="$REPO/results/week4"
IDXDIR="$OUT/hisat2_index"
SAMPLES="1_control 1_treated 2_control 2_treated"
THREADS="$(nproc)"

# ---------------------------------------------------------------------------
# 0. 도구 준비 - hisat2, samtools
#    sudo 를 쓸 수 없는 환경이라 micromamba 로 홈 디렉터리에 설치한다.
#    이미 깔려 있으면 건너뛴다.
# ---------------------------------------------------------------------------
OPT="$HOME/opt"
ENV="$OPT/envs/align"
export MAMBA_ROOT_PREFIX="$OPT/mamba"
export PATH="$OPT/bin:$ENV/bin:$PATH"

if ! command -v micromamba >/dev/null 2>&1; then
    mkdir -p "$OPT/bin"
    cd "$OPT"
    curl -Ls -o mm.tar.bz2 https://micro.mamba.pm/api/micromamba/linux-64/latest
    # bzip2 명령이 없는 환경이라 python 의 bz2 모듈로 푼다
    python3 -c "import bz2,shutil; shutil.copyfileobj(bz2.open('mm.tar.bz2','rb'), open('mm.tar','wb'))"
    tar -xf mm.tar bin/micromamba
    rm -f mm.tar.bz2 mm.tar
    cd - >/dev/null
fi

if [ ! -x "$ENV/bin/hisat2" ] || [ ! -x "$ENV/bin/samtools" ]; then
    micromamba create -y -p "$ENV" -c conda-forge -c bioconda hisat2 samtools
fi

hisat2 --version | head -1
samtools --version | head -1

# ---------------------------------------------------------------------------
# 1. 출력 폴더와 참조 서열 준비
#    hisat2-build 는 gzip 으로 묶인 FASTA 를 못 읽으므로 풀어서 쓴다.
#    data/ 의 원본 .gz 는 건드리지 않는다.
# ---------------------------------------------------------------------------
mkdir -p "$IDXDIR"
gzip -dc "$W4/hg19_chr1_11.4Mb.fa.gz" > "$IDXDIR/hg19_chr1_11.4Mb.fa"

# ---------------------------------------------------------------------------
# 2. hisat2 인덱스 구축
# ---------------------------------------------------------------------------
hisat2-build -p "$THREADS" "$IDXDIR/hg19_chr1_11.4Mb.fa" "$IDXDIR/hg19_chr1"

# ---------------------------------------------------------------------------
# 3. 샘플마다 정렬 -> 좌표순 정렬 -> BAM 인덱스
#    SAM 을 디스크에 쓰지 않고 파이프로 samtools sort 에 바로 넘긴다.
# ---------------------------------------------------------------------------
for S in $SAMPLES; do
    echo "=== $S ==="
    hisat2 -p "$THREADS" -x "$IDXDIR/hg19_chr1" \
           -1 "$W4/${S}.R1.fastq.gz" -2 "$W4/${S}.R2.fastq.gz" \
           --summary-file "$OUT/${S}.hisat2.summary.txt" \
        | samtools sort -@ "$THREADS" -o "$OUT/${S}.sorted.bam" -

    samtools index -@ "$THREADS" "$OUT/${S}.sorted.bam"
    cat "$OUT/${S}.hisat2.summary.txt"
done

# ---------------------------------------------------------------------------
# 4. 결과 확인
# ---------------------------------------------------------------------------
ls -la "$OUT"
for S in $SAMPLES; do
    echo "=== $S ==="
    samtools flagstat "$OUT/${S}.sorted.bam" | sed -n '1p;7p;12p;14p'
    samtools view -H "$OUT/${S}.sorted.bam" | grep '^@HD'
done
