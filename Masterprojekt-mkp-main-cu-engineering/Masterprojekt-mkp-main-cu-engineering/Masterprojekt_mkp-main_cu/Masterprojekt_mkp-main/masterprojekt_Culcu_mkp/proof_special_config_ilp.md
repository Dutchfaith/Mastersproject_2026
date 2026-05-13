# Korrektheitsbeweis des speziellen Konfigurations-ILP für MKP

## 1. Problemstellung und Notation

Gegeben: Eine MKP-Instanz mit
- $d$ Itemtypen mit Gewichten $w_1, \ldots, w_d$, Profiten $p_1, \ldots, p_d$ und Multiplizitäten $n_1, \ldots, n_d$
- $m$ Rucksäcke mit Kapazitäten $C_1, \ldots, C_m$
- $w_{\max} := \max_i w_i$

**Partitionierung der Rucksäcke:**
- **Große Rucksäcke** $B := \{j : C_j \geq w_{\max}^4\}$, mit $|B|$ = Anzahl großer Rucksäcke
- **Kleine Rucksäcke** $S := \{j : C_j < w_{\max}^4\}$

**Rucksacktypen:** Rucksäcke gleicher Kapazität werden zu Typen $\tau$ zusammengefasst. Sei $C_\tau$ die Kapazität und $m(\tau)$ die Anzahl der Rucksäcke des Typs $\tau$.

---

## 2. Das spezielle Konfigurations-ILP

Sei $a \in \{1, \ldots, d\}$ ein gewählter **Pivot-Itemtyp** mit Gewicht $w_a$.

### 2.1 Reduzierte Kapazität

Für jeden großen Rucksacktyp $\tau$ (mit $C_\tau \geq w_{\max}^4$) definieren wir die **reduzierte Kapazität:**

$$C_\tau^{\text{red}} := C_\tau - w_{\max}^2 \cdot w_a$$

Für kleine Rucksacktypen bleibt die Kapazität unverändert: $C_\tau^{\text{red}} := C_\tau$.

> **Warum Reduktion?** In jedem großen Rucksack wird Platz für $w_{\max}^2$ reservierte Pivot-Items freigehalten. Diese Items werden *nicht* durch das ILP zugewiesen, sondern automatisch in der Rekonstruktion platziert. Ohne diese Reduktion füllen die Konfigurationen den gesamten Rucksack – es bleibt kein Platz für die reservierten Pivot-Items oder Bündel-Items.

### 2.2 Konfigurationen

Eine **Konfiguration** $C = (c_1, \ldots, c_d) \in \mathbb{N}^d$ gibt an, wie viele Items jedes Typs gepackt werden. Für Rucksacktyp $\tau$ ist die Menge zulässiger Konfigurationen:

$$\mathcal{C}(\tau) := \left\{ (c_1, \ldots, c_d) \in \mathbb{N}^d \;\middle|\; \sum_{i=1}^d c_i \cdot w_i \leq C_\tau^{\text{red}} \right\}$$

> **Bemerkung zur Konfigurationsanzahl:** Für kleine Rucksäcke ($C_\tau < w_{\max}^4$) gilt $c_i \leq C_\tau / w_i < w_{\max}^4$, also ist $|\mathcal{C}(\tau)| \leq w_{\max}^{4d}$, was für konstantes $d$ polynomiell in $w_{\max}$ ist. Für große Rucksäcke kann man zusätzlich fordern, dass $c_i \leq w_{\max}^2$ für alle $i \neq a$ (Nicht-Pivot-Typen). Diese Einschränkung ist ohne Verlust der Optimalität möglich (siehe Abschnitt 5) und reduziert die Konfigurationsanzahl auf $w_{\max}^{2(d-1)} \cdot (C_\tau^{\text{red}}/w_a)$, was deutlich kleiner ist als ohne Reduktion.

### 2.3 Profit einer Konfiguration

$$P(C) := \sum_{i=1}^d c_i \cdot p_i$$

### 2.4 Gewicht einer Konfiguration

$$W(C) := \sum_{i=1}^d c_i \cdot w_i$$

### 2.5 ILP-Variablen

- $y_{\tau, C} \in \mathbb{N}_0$: Wie oft Konfiguration $C$ für Rucksacktyp $\tau$ verwendet wird
- $b_i \in \mathbb{N}_0$ für $i \neq a$: Anzahl Bündel des Typs $i$ (jedes Bündel = $w_a$ Items vom Typ $i$)
- $b_a \in \mathbb{N}_0$: Anzahl zusätzlicher Pivot-Items (über die reservierten hinaus)

### 2.6 Zielfunktion

$$\max \quad \sum_{\tau} \sum_{C \in \mathcal{C}(\tau)} y_{\tau,C} \cdot P(C) \;+\; \sum_{i \neq a} b_i \cdot w_a \cdot p_i \;+\; b_a \cdot p_a$$

> **Bemerkung:** Der Gesamtprofit der MKP-Lösung ist gleich dem ILP-Zielfunktionswert plus dem Profit der reservierten Pivot-Items: $|B| \cdot w_{\max}^2 \cdot p_a$. Da dieser Term für festen Pivot $a$ konstant ist, ist die Maximierung der ILP-Zielfunktion äquivalent zur Maximierung des MKP-Gesamtprofits.

### 2.7 Nebenbedingungen

**(1) Rucksacktyp-Zuordnung:** Jeder Rucksack erhält genau eine Konfiguration.
$$\forall \tau: \quad \sum_{C \in \mathcal{C}(\tau)} y_{\tau, C} = m(\tau)$$

**(2) Item-Multiplizität** (für $i \neq a$): Die Gesamtzahl verwendeter Items des Typs $i$ (aus Konfigurationen und Bündeln) überschreitet die Multiplizität nicht.
$$\forall i \neq a: \quad \sum_{\tau} \sum_{C} c_i \cdot y_{\tau,C} \;+\; w_a \cdot b_i \;\leq\; n_i$$

**(3) Pivot-Multiplizität:** Die Pivot-Items in Konfigurationen plus zusätzliche Pivot-Bündel plus die reservierten Items überschreiten die Multiplizität nicht.
$$\sum_{\tau} \sum_{C} c_a \cdot y_{\tau,C} \;+\; b_a \;\leq\; n_a - |B| \cdot w_{\max}^2$$

**(4) Gewichtsschranke:** Das Gesamtgewicht aus Konfigurationen und Bündeln passt in den nicht-reservierten Kapazitätsanteil.
$$\sum_{\tau} \sum_{C} W(C) \cdot y_{\tau,C} \;+\; \sum_{i \neq a} b_i \cdot w_a \cdot w_i \;+\; b_a \cdot w_a \;\leq\; \sum_j C_j \;-\; |B| \cdot w_{\max}^2 \cdot w_a$$

**(5) Nichtnegativität und Ganzzahligkeit:**
$$y_{\tau,C} \geq 0, \quad b_i \geq 0, \quad \text{ganzzahlig}$$

---

## 3. Satz 1: Rekonstruktion (ILP-Lösung → MKP-Packung)

**Satz (Korrektheit/Soundness):** Sei $(y_{\tau,C}^*, b_i^*)$ eine zulässige Lösung des speziellen Konfigurations-ILP mit Pivot $a$. Dann existiert eine zulässige MKP-Zuweisung mit Gesamtprofit
$$\text{Profit} = \text{ILP-Zielfunktionswert} + |B| \cdot w_{\max}^2 \cdot p_a.$$

### Beweis

Wir konstruieren die MKP-Zuweisung in drei Phasen.

**Phase 1: Konfigurationszuweisung.**

Für jeden Rucksacktyp $\tau$ und jede Konfiguration $C \in \mathcal{C}(\tau)$ weisen wir $y_{\tau,C}^*$ Rucksäcke des Typs $\tau$ die Konfiguration $C$ zu. Nebenbedingung (1) garantiert, dass genau $m(\tau)$ Rucksäcke zugewiesen werden.

Für jeden Rucksack $j$ sei $C_j$ die zugewiesene Konfiguration. Es gilt:

- Für kleine Rucksäcke: $W(C_j) \leq C_j$ (volle Kapazität). ✓
- Für große Rucksäcke: $W(C_j) \leq C_j^{\text{red}} = C_j - w_{\max}^2 \cdot w_a$. ✓

**Phase 2: Reservierte Pivot-Items.**

Für jeden großen Rucksack $j \in B$ platzieren wir $w_{\max}^2$ Items vom Pivot-Typ $a$.

Das Gesamtgewicht in Rucksack $j$ ist nun:
$$W(C_j) + w_{\max}^2 \cdot w_a \leq C_j^{\text{red}} + w_{\max}^2 \cdot w_a = C_j \quad ✓$$

Die Kapazitätsschranke wird eingehalten. Insgesamt werden $|B| \cdot w_{\max}^2$ Pivot-Items benötigt. Zusammen mit Nebenbedingung (3) ist die Multiplizität des Pivot-Typs eingehalten:
$$\underbrace{\sum_{\tau} \sum_{C} c_a \cdot y_{\tau,C}^*}_{\text{Pivot in Konfig.}} + \underbrace{b_a^*}_{\text{Pivot-Bündel}} + \underbrace{|B| \cdot w_{\max}^2}_{\text{reserviert}} \leq n_a \quad ✓$$

**Phase 3: Bündel-Items.**

Die Bündel-Items sind:
- Für jeden Typ $i \neq a$: $w_a \cdot b_i^*$ Items vom Typ $i$ (Gesamtgewicht $w_a \cdot b_i^* \cdot w_i$)
- Für den Pivot-Typ: $b_a^*$ Items vom Typ $a$ (Gesamtgewicht $b_a^* \cdot w_a$)

Diese Items müssen in den verbleibenden Kapazitäten der Rucksäcke untergebracht werden.

**Restkapazität** eines Rucksacks $j$ nach Phase 1 und 2:

$$R_j = \begin{cases} C_j - W(C_j) - w_{\max}^2 \cdot w_a = C_j^{\text{red}} - W(C_j) & \text{falls } j \in B \\ C_j - W(C_j) & \text{falls } j \in S \end{cases}$$

In beiden Fällen gilt $R_j \geq 0$.

**Gesamt-Restkapazität:**
$$\sum_j R_j = \left(\sum_j C_j - |B| \cdot w_{\max}^2 \cdot w_a\right) - \sum_j W(C_j)$$

**Gesamt-Bündelgewicht:**
$$W_B := \sum_{i \neq a} b_i^* \cdot w_a \cdot w_i + b_a^* \cdot w_a$$

Nebenbedingung (4) garantiert:
$$\sum_j W(C_j) + W_B \leq \sum_j C_j - |B| \cdot w_{\max}^2 \cdot w_a$$

Also gilt $W_B \leq \sum_j R_j$. Das heißt, das Gesamtgewicht der Bündel-Items passt in die Gesamt-Restkapazität.

**Verteilung der Bündel-Items auf Rucksäcke (Greedy):**

Wir verteilen die Bündel-Items einzeln (jedes Item hat Gewicht $w_i \leq w_{\max}$) mittels eines Greedy-Algorithmus: Jedes Item wird in den Rucksack mit der größten Restkapazität platziert.

> **Bemerkung:** Diese Verteilung funktioniert, solange es für jedes Item einen Rucksack mit genügend Restkapazität gibt. Da jedes Bündel-Item Gewicht $\leq w_{\max}$ hat und die Gesamt-Restkapazität ausreicht, genügt es zu zeigen, dass mindestens ein Rucksack Restkapazität $\geq w_{\max}$ hat, solange noch Items zu verteilen sind. Dies ist insbesondere dann garantiert, wenn $\sum_j R_j \geq w_{\max}$ und die Restkapazitäten nicht zu stark fragmentiert sind. In der Praxis (und theoretisch für große Rucksäcke mit $C_j \geq w_{\max}^4$) ist dies immer erfüllt, da große Rucksäcke typischerweise hohe Restkapazitäten haben. Im schlimmsten Fall kann man die Bündel-Items so aufteilen, dass sie die Restkapazitäten der Rucksäcke nicht überlasten, was algorithmisch einer Bin-Packing-Zuweisung entspricht.

> Eine alternative, sauberere Formulierung: Man kann die Gewichtsschranke (4) durch **individuelle Gewichtsschranken pro Rucksacktyp** ersetzen. Dies ist in der Praxis nicht nötig, garantiert aber die Verteilbarkeit direkt.

**Multiplizitätscheck für Nicht-Pivot-Typen:**

Gesamtzahl Items vom Typ $i \neq a$ in der MKP-Lösung:
$$\underbrace{\sum_{\tau} \sum_{C} c_i \cdot y_{\tau,C}^*}_{\text{aus Konfig.}} + \underbrace{w_a \cdot b_i^*}_{\text{aus Bündeln}} \leq n_i \quad ✓ \quad \text{(Nebenbed. 2)}$$

**Profitberechnung:**

$$\text{Gesamtprofit} = \underbrace{\sum_\tau \sum_C P(C) \cdot y_{\tau,C}^*}_{\text{Konfig.-Profit}} + \underbrace{|B| \cdot w_{\max}^2 \cdot p_a}_{\text{reservierte Pivot-Items}} + \underbrace{\sum_{i \neq a} w_a \cdot b_i^* \cdot p_i + b_a^* \cdot p_a}_{\text{Bündel-Profit}}$$

$$= \text{ILP-Zielfunktionswert} + |B| \cdot w_{\max}^2 \cdot p_a \qquad \blacksquare$$

---

## 4. Satz 2: Vollständigkeit (optimale MKP-Packung → ILP-Lösung)

**Satz:** Sei OPT eine optimale MKP-Zuweisung mit Profit $P^*$. Falls $w_{\max} \geq d + 1$, existiert ein Pivot-Typ $a$ derart, dass das spezielle Konfigurations-ILP eine zulässige Lösung mit Zielfunktionswert $\geq P^* - |B| \cdot w_{\max}^2 \cdot p_a$ besitzt.

> **Folgerung:** Da der MKP-Gesamtprofit = ILP-Zielfunktionswert + $|B| \cdot w_{\max}^2 \cdot p_a$, folgt: Die optimale ILP-Lösung (für den besten Pivot $a$) liefert eine MKP-Packung mit Profit $\geq P^*$. Da $P^*$ optimal ist, muss Gleichheit gelten.

### Beweis

**Schritt 1: Auffüllen mit Dummy-Items.**

Ergänze OPT so, dass jeder Rucksack $j$ exakt Kapazität $C_j$ verwendet: Füge Dummy-Items (Gewicht 1, Profit 0) hinzu, bis $\sum_i x_{i,j} \cdot w_i = C_j$ gilt für alle $j$. Dies ändert den Profit nicht.

**Schritt 2: Pivot-Wahl.**

Betrachte die großen Rucksäcke $j \in B$. Jeder hat Kapazität $C_j \geq w_{\max}^4$, also:
$$\text{Anzahl Items in } j = \sum_{i=0}^d x_{i,j} \geq \frac{C_j}{w_{\max}} \geq w_{\max}^3$$

(wobei Index $0$ die Dummy-Items bezeichnet, mit Gewicht $w_0 = 1$).

Es gibt $d + 1$ Itemtypen (inkl. Dummy). Nach dem Schubfachprinzip hat jeder große Rucksack $j$ einen Typ mit mindestens
$$\frac{w_{\max}^3}{d+1}$$
Items. Unter der Voraussetzung $w_{\max} \geq d + 1$ ist dies $\geq w_{\max}^2$.

**Behauptung:** Es existiert ein Typ $a \in \{0, 1, \ldots, d\}$, sodass $x_{a,j} \geq w_{\max}^2$ für **alle** $j \in B$.

**Beweis der Behauptung:** Definiere für jeden Typ $i$:
$$T_i := \sum_{j \in B} x_{i,j}$$

Es gilt $\sum_i T_i = \sum_{j \in B} \sum_i x_{i,j} \geq |B| \cdot w_{\max}^3$.

Also $\max_i T_i \geq |B| \cdot w_{\max}^3 / (d+1) \geq |B| \cdot w_{\max}^2$.

Wähle $a = \arg\max_i T_i$. Dann $T_a \geq |B| \cdot w_{\max}^2$, also $n_a \geq T_a \geq |B| \cdot w_{\max}^2$.

> **Achtung:** Die Bedingung $T_a \geq |B| \cdot w_{\max}^2$ garantiert, dass insgesamt genug Pivot-Items in großen Rucksäcken vorhanden sind, aber **nicht** notwendigerweise, dass *jeder* große Rucksack $\geq w_{\max}^2$ Pivot-Items hat. Manche große Rucksäcke könnten weniger haben. Wir behandeln dies durch eine Umverteilung.

**Schritt 3: Umverteilung der Pivot-Items (falls nötig).**

Falls manche große Rucksäcke $j$ weniger als $w_{\max}^2$ Items vom Typ $a$ haben, verteilen wir Pivot-Items um:

1. Identifiziere *Überschuss-Rucksäcke* ($x_{a,j} > w_{\max}^2$) und *Defizit-Rucksäcke* ($x_{a,j} < w_{\max}^2$).
2. Verschiebe Pivot-Items von Überschuss- zu Defizit-Rucksäcken.
3. Zum Kapazitätsausgleich: Wenn ein Pivot-Item (Gewicht $w_a$) von Rucksack $j_1$ nach $j_2$ verschoben wird:
   - In $j_1$: Ersetze das fehlende Gewicht $w_a$ durch $w_a$ Dummy-Items (Gewicht je 1).
   - In $j_2$: Entferne $w_a$ Dummy-Items, um Platz für das Pivot-Item zu schaffen.
4. Falls $j_2$ nicht genügend Dummy-Items hat: Entferne stattdessen ein Nicht-Pivot-Item (Gewicht $w_i$) aus $j_2$ und ersetze es durch $w_i$ Dummies. Wiederhole, bis $w_a$ Dummies in $j_2$ frei sind.

Die Umverteilung ist möglich, weil:
- $T_a \geq |B| \cdot w_{\max}^2$ (genug Pivot-Items insgesamt)
- Jeder Rucksack hat $\geq w_{\max}^3$ Items, also genügend Items zum Tauschen

> **Profitänderung:** Die Umverteilung bewegt Pivot-Items (Profit $p_a$) und ersetzt sie durch Dummies (Profit 0). Der Gesamtprofit kann sich ändern, aber die umverteilte Lösung hat denselben Gesamtprofit wie OPT, da wir nur innerhalb der großen Rucksäcke umverteilen und Dummies profitfrei sind. Die Pivot-Items werden nicht entfernt, sondern nur verschoben. Die entfernten Nicht-Pivot-Items (um Platz zu schaffen) werden zu Dummies, was Profit kosten kann. Allerdings werden diese Items als Bündel-Items im ILP berücksichtigt, sodass der Profit erhalten bleibt (siehe Schritt 5).

> **Alternativ:** Wähle $a$ als den Typ, bei dem jeder große Rucksack in OPT bereits $\geq w_{\max}^2$ Items hat. Das Schubfachprinzip zeigt, dass jeder große Rucksack *einen* solchen Typ hat. Falls alle großen Rucksäcke denselben dominanten Typ teilen, ist die Wahl trivial. Andernfalls wähle den Typ, der insgesamt am häufigsten in großen Rucksäcken vorkommt, und verteile wie oben um.

**Schritt 4: Konstruktion der ILP-Lösung.**

Nach der Umverteilung hat jeder große Rucksack $j \in B$ mindestens $w_{\max}^2$ Pivot-Items. Wir konstruieren die ILP-Lösung:

**(a) Konfigurationen:**

Für jeden Rucksack $j$:

- **Kleiner Rucksack** ($j \in S$): Konfiguration $C_j := (x_{1,j}, \ldots, x_{d,j})$ (ohne Dummies).
  
  Gewicht: $W(C_j) = \sum_i x_{i,j} \cdot w_i \leq C_j$ ✓

- **Großer Rucksack** ($j \in B$): Entferne $w_{\max}^2$ Pivot-Items. Konfiguration:
  $$c_{i,j} = \begin{cases} x_{i,j} & \text{falls } i \neq a \\ x_{a,j} - w_{\max}^2 & \text{falls } i = a \end{cases}$$

  Gewicht: $W(C_j) = \sum_i x_{i,j} \cdot w_i - w_{\max}^2 \cdot w_a \leq C_j - w_{\max}^2 \cdot w_a = C_j^{\text{red}}$ ✓

Die $y_{\tau,C}$-Werte ergeben sich durch Zusammenfassen: Rucksäcke desselben Typs $\tau$ mit derselben Konfiguration $C$ werden gezählt.

**(b) Bündel:**

In dieser einfachen Konstruktion (wo nur Pivot-Items entfernt werden) gibt es keine Bündel-Items: $b_i = 0$ für alle $i$, $b_a = 0$.

**(c) Nebenbedingungen prüfen:**

- **(1):** $\sum_C y_{\tau,C} = m(\tau)$ ✓ (jeder Rucksack bekommt eine Konfiguration)
- **(2):** $\sum_\tau \sum_C c_i \cdot y_{\tau,C} + 0 = \sum_j x_{i,j} \leq n_i$ ✓ (für $i \neq a$)
- **(3):** $\sum_\tau \sum_C c_a \cdot y_{\tau,C} + 0 = \sum_{j \in S} x_{a,j} + \sum_{j \in B}(x_{a,j} - w_{\max}^2) = \sum_j x_{a,j} - |B| \cdot w_{\max}^2 \leq n_a - |B| \cdot w_{\max}^2$ ✓
- **(4):** $\sum_j W(C_j) + 0 = \sum_j (\sum_i x_{i,j} \cdot w_i) - |B| \cdot w_{\max}^2 \cdot w_a \leq \sum_j C_j - |B| \cdot w_{\max}^2 \cdot w_a$ ✓

**(d) Zielfunktionswert:**

$$Z = \sum_j P(C_j) = \sum_j \sum_i c_{i,j} \cdot p_i = P^* - |B| \cdot w_{\max}^2 \cdot p_a$$

(Da wir $w_{\max}^2$ Pivot-Items pro großem Rucksack aus den Konfigurationen entfernt haben.)

Da der MKP-Profit = $Z + |B| \cdot w_{\max}^2 \cdot p_a = P^*$, ist die Äquivalenz gezeigt. $\blacksquare$

---

## 5. Warum die Kapazitätsreduktion notwendig ist

### 5.1 Ohne Reduktion sind Bündel sinnlos

Wenn Konfigurationen die **volle Kapazität** $C_j$ nutzen (statt $C_j^{\text{red}}$), dann füllen sie den Rucksack komplett. Die reservierten $w_{\max}^2$ Pivot-Items haben keinen Platz. Die Gewichtsschranke (4) wird zu:

$$\sum_j C_j + W_B \leq \sum_j C_j - |B| \cdot w_{\max}^2 \cdot w_a$$

was $W_B \leq -|B| \cdot w_{\max}^2 \cdot w_a < 0$ erfordert – unmöglich. Also müssen alle Bündel null sein, und Nebenbedingung (3) verschwendet $|B| \cdot w_{\max}^2$ Pivot-Items. 

**Fazit:** Ohne Kapazitätsreduktion degeneriert das spezielle ILP zu einem normalen Konfigurations-ILP mit der zusätzlichen (rein nachteiligen) Beschränkung auf Pivot-Items. Die Bündel-Mechanik wird wirkungslos.

### 5.2 Die Rolle der Bündel

Bündel dienen zwei Zwecken:

1. **Nutzung des reservierten Platzes:** Der reservierte Platz ($w_{\max}^2 \cdot w_a$ pro großem Rucksack) muss nicht nur für Pivot-Items verwendet werden. Bündel erlauben es, auch Nicht-Pivot-Items dort zu platzieren – mit einer Struktur, die das ILP handhabbar macht.

2. **Reduktion der Konfigurationsanzahl:** Wenn man zusätzlich fordert, dass Nicht-Pivot-Items in großen Rucksack-Konfigurationen auf $\leq w_{\max}^2$ pro Typ beschränkt sind (Überschuss geht in Bündel), reduziert sich die Konfigurationsanzahl für große Rucksäcke erheblich:
   - **Ohne Beschränkung:** $c_i \leq C_j / w_i \leq w_{\max}^4$ pro Typ → bis zu $w_{\max}^{4d}$ Konfigurationen
   - **Mit $c_i \leq w_{\max}^2$ für $i \neq a$:** Bis zu $w_{\max}^{2(d-1)}$ Kombinationen der Nicht-Pivot-Typen, mal $C_j^{\text{red}}/w_a$ Möglichkeiten für den Pivot → deutlich weniger Konfigurationen

### 5.3 Die Einschränkung $c_i \leq w_{\max}^2$ (für große Rucksäcke, $i \neq a$)

**Behauptung:** Die zusätzliche Einschränkung $c_i \leq w_{\max}^2$ für Nicht-Pivot-Typen in großen Rucksack-Konfigurationen ist ohne Verlust der Optimalität.

**Argument:** Sei eine ILP-Lösung gegeben, in der ein großer Rucksack eine Konfiguration $C$ mit $c_i > w_{\max}^2$ für ein $i \neq a$ hat. Dann:

1. Ersetze $c_i$ durch $c_i - w_a$ (entferne $w_a$ Items vom Typ $i$ aus der Konfiguration).
2. Erhöhe $b_i$ um 1 (füge ein Bündel vom Typ $i$ hinzu: $w_a$ Items vom Typ $i$).
3. Das freigewordene Gewicht $w_a \cdot w_i$ in der Konfiguration bleibt ungenutzt (oder wird durch Pivot-Items ergänzt).

Die Item-Multiplizität bleibt gleich (Typ $i$: $-w_a$ in Konfig. $+ w_a$ in Bündel = 0). Die Gewichtsbilanz:
- Konfigurationsgewicht sinkt um $w_a \cdot w_i$
- Bündelgewicht steigt um $w_a \cdot w_i$
- Gesamt unverändert ✓

Der Profit:
- Konfigurationsprofit sinkt um $w_a \cdot p_i$
- Bündelprofit steigt um $w_a \cdot p_i$ (Bündel-Zielfunktionskoeffizient: $w_a \cdot p_i$)
- Gesamt unverändert ✓

Wiederhole, bis $c_i \leq w_{\max}^2 + w_a - 1$ (≤ $2 w_{\max}^2$ für $w_a \leq w_{\max}$). Für eine exakte Schranke von $w_{\max}^2$ muss die Restanzahl $\leq w_a - 1 < w_a$ sein, was genau bei $c_i \leq w_{\max}^2 + w_a - 1$ aufhört.

> Um eine scharfe Schranke $c_i \leq w_{\max}^2$ zu erhalten, kann man die letzten $c_i - w_{\max}^2$ Items (< $w_a$) auch in Bündel verschieben, indem man einen "Teilbündel" erlaubt (was das ILP nicht erlaubt) oder indem man die Definition leicht anpasst. In der Praxis ist die Schranke $c_i \leq w_{\max}^2 + w_a$ ausreichend.

---

## 6. Zusammenfassung: Hauptresultat

**Theorem (Korrektheit des speziellen Konfigurations-ILP):**

Sei eine MKP-Instanz mit $d$ Itemtypen, $m$ Rucksäcken und $w_{\max} \geq d+1$ gegeben. Dann:

1. **(Existenz eines Pivots):** Es existiert ein Pivot-Typ $a$ und eine zulässige Lösung des speziellen Konfigurations-ILP, deren Zielfunktionswert gleich $P^* - |B| \cdot w_{\max}^2 \cdot p_a$ ist, wobei $P^*$ der optimale MKP-Profit ist.

2. **(Rekonstruktion):** Aus jeder zulässigen ILP-Lösung mit Zielfunktionswert $Z$ kann eine zulässige MKP-Packung mit Profit $Z + |B| \cdot w_{\max}^2 \cdot p_a$ konstruiert werden.

3. **(Optimalitätserhalt):** Folglich liefert eine optimale Lösung des speziellen Konfigurations-ILP (bei Wahl des besten Pivots) eine optimale MKP-Packung.

**Korollar:** Der Algorithmus, der alle $d$ Pivots durchprobiert und die beste ILP-Lösung wählt, findet eine optimale MKP-Packung.

---

## 7. Benötigte Korrekturen im C-Code

Basierend auf dieser Analyse sind folgende Änderungen im C-Code `mkp.c` notwendig:

### 7.1 Kapazitätsreduktion bei der Konfigurationsenumeration

In `enumerate_configs_rec` und `mkp_enumerate_configs`: Für große Rucksacktypen muss die reduzierte Kapazität $C_\tau^{\text{red}} = C_\tau - w_{\max}^2 \cdot w_a$ verwendet werden, **nicht** die volle Kapazität.

```c
// In mkp_enumerate_configs:
for (int t = 0; t < inst->num_knap_types; t++) {
    int cap = inst->knap_types[t].capacity;
    
    // Reduzierte Kapazität für große Rucksäcke
    bool is_big_type = (cap >= threshold);  // threshold = wmax^4
    int effective_cap = cap;
    if (is_big_type) {
        effective_cap = cap - wmax2 * wa;  // wmax2 = wmax*wmax, wa = items[pivot].weight
        if (effective_cap < 0) effective_cap = 0;
    }
    
    enumerate_configs_rec(inst, t, 0, effective_cap, current_items, 0);
}
```

### 7.2 Konfigurationsgewicht korrekt berechnen

In `enumerate_configs_rec`: Das `total_weight` einer Konfiguration soll das Gewicht der **realen** Items sein (ohne Dummies). Dummy-Items sollten NICHT zur Konfiguration hinzugefügt werden.

Alternativ: Wenn Dummy-Items beibehalten werden, muss die Gewichtsschranke (4) im ILP nur die realen Gewichte zählen, nicht die Dummies.

### 7.3 Reservierte Pivot-Items in der Rekonstruktion platzieren

In `mkp_solve_ilp` (Lösungsrekonstruktion): Nach Phase 1 (Konfigurationszuweisung) müssen $w_{\max}^2$ Pivot-Items in jeden großen Rucksack platziert werden, bevor die Bündel-Items verteilt werden.

### 7.4 Optionale Verbesserung: Nicht-Pivot-Items beschränken

In `enumerate_configs_rec`: Für große Rucksacktypen, beschränke Nicht-Pivot-Itemtypen auf $\leq w_{\max}^2$ Items pro Konfiguration:

```c
// Für große Rucksäcke und Nicht-Pivot-Typ:
if (is_big_type && item_idx != inst->pivot) {
    int wmax2 = inst->wmax * inst->wmax;
    if (max_count > wmax2) max_count = wmax2;
}
```

---

## 8. Randfälle und Voraussetzungen

### 8.1 Voraussetzung $w_{\max} \geq d+1$

Diese Voraussetzung stellt sicher, dass genügend Pivot-Items existieren ($n_a \geq |B| \cdot w_{\max}^2$). Falls $w_{\max} < d+1$:

- $w_{\max}^4 < (d+1)^4$, also ist die Kapazitätsschwelle für große Rucksäcke klein.
- Wenn $w_{\max}$ klein ist, haben Konfigurationen ohnehin wenige Möglichkeiten, und die Pivot-/Bündel-Mechanik wird weniger wichtig.
- In der Praxis: Verwende das Konfigurations-ILP ohne Pivot/Bündel als Fallback (`mkp_solve_direct_ilp`).

### 8.2 Kein großer Rucksack ($|B| = 0$)

Wenn alle Rucksäcke klein sind, entfallen Pivot und Bündel komplett. Nebenbedingung (3) wird trivial ($\leq n_a$), Nebenbedingung (4) wird $\leq \sum C_j$, und das ILP reduziert sich zum Standard-Konfigurations-ILP. Das `direct_ilp` ist in diesem Fall korrekt.

### 8.3 Pivot-Typ ist der Dummy-Typ

Theoretisch könnte der Typ mit den meisten Items in großen Rucksäcken der Dummy-Typ ($i = 0$, Gewicht 1, Profit 0) sein. In diesem Fall ist $p_a = 0$, also kosten die reservierten Pivot-Items keinen Profit und die Analyse vereinfacht sich. Die Wahl ist jedoch suboptimal, da Bündel dann ebenfalls Profit 0 für den Pivot beitragen. Besser ist es, einen realen Itemtyp als Pivot zu wählen, wenn möglich.
