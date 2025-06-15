#!/usr/bin/env bash
#
#  seed_categories.sh
#  ------------------
#  Bulk-insert / update 19 canonical categories into MediaCMS.
#
#  Usage
#    ./seed_categories.sh                 # container 預設 mediacms-web-1
#    ./seed_categories.sh my_container    # 指定 container
#

# ─── CLI 參數 ────────────────────────────────────────────────────
CONTAINER=${1:-mediacms-web-1}   # Docker container name / ID
# ────────────────────────────────────────────────────────────────

docker exec -i "$CONTAINER" bash <<'EOF'
set -e

python manage.py shell <<'PY'
from django.db import transaction

# 固定路徑：files.models.Category
from files.models import Category

CATEGORIES = [
    ("後端架構",  "聚焦雲端微服務、Django、Redis 與容器化部署。深入系統設計與效能調校，打造可水平擴充的後端。"),
    ("前端體驗",  "Angular、Chart.js、RxJS 與 UI/UX 範例全收錄。介面美觀且高互動。"),
    ("程式語言",  "Python、TypeScript 等語法與設計模式，強化跨語言思維。"),
    ("資料與 AI", "資料管線、爬蟲到生成式 AI；分析、建模、MLOps 一應俱全。"),
    ("雲端運維",  "CI/CD、IaC、SRE 與 FinOps 實戰；雲端持續交付並穩定監控。"),
    ("測試品質",  "Pytest、E2E、自動化測試框架；推動 TDD/BDD，寫出高品質程式。"),
    ("資訊安全",  "OAuth 2.0、TLS、零信任與攻防實戰；守護程式碼與資料安全。"),
    ("演算法效能", "從 Bee Colony Optimization 到 Rate-Limiting；優化資源、提升吞吐量。"),
    ("產品思維",  "Revenue Funnel、Scenario 設計、用戶旅程；銜接技術與商業。"),
    ("效率工具",  "Google Calendar 祕技、Copilot、DevTools… 工作流加速器。"),
    ("領導管理",  "團隊領導、專案治理與績效管理；打造教練式領導力。"),
    ("說話溝通",  "ChatGPT 對話、簡報與談判技巧；把複雜概念講到人人都懂。"),
    ("職涯技能",  "面試技巧、績效評等與技能藍圖；打造長期職涯護城河。"),
    ("財務智慧",  "人生資產配置、稅務優化、ESG 投資；職涯與財富並進。"),
    ("心理人際",  "四色人格、會議效率、協作心理學；解鎖團隊動力。"),
    ("銷售推廣",  "銷售流程、提案策略與客戶經營；精準傳遞產品價值。"),
    ("市場動態",  "產業趨勢、競品分析與模式演進；洞悉市場新機會。"),
    ("興趣分享",  "手作、旅遊、攝影等跨界交流；激發創意火花。"),
    ("運動健康",  "工作伸展、居家鍛鍊與人體工學；守護開發者身心。"),
]

total = len(CATEGORIES)
created = updated = 0

with transaction.atomic():
    for idx, (title, description) in enumerate(CATEGORIES, start=1):
        obj, is_created = Category.objects.update_or_create(
            title=title,
            defaults=dict(description=description, is_global=True),
        )
        action = "🆕  Created" if is_created else "✏️    Updated"
        print(f"{idx:02d}/{total} {action} «{title}»")
        if is_created:
            created += 1
        else:
            updated += 1

print(f"\n✅  Category seeding finished → created={created}, updated={updated}")
PY
EOF
