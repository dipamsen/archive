(
draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 0, label: <s>),
    vertex(name: $a$, height: 0, excess: 10, label: <a>),
    vertex(name: $b$, height: 0, excess: 10, label: <b>),
    vertex(name: $t$, height: 0, excess: 0, label: <t>),
  ),
  (
    (<a>, <s>, 10),
    (<b>, <s>, 10),
    (<a>, <b>, 2),
    (<a>, <t>, 4, -30deg),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 0, label: <s>),
    vertex(name: $a$, height: 1, excess: 10, label: <a>),
    vertex(name: $b$, height: 0, excess: 10, label: <b>),
    vertex(name: $t$, height: 0, excess: 0, label: <t>),
  ),
  (
    (<a>, <s>, 10),
    (<b>, <s>, 10, -20deg),
    (<a>, <b>, 2, 0deg, true),
    (<a>, <t>, 4, 30deg),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 0, label: <s>),
    vertex(name: $a$, height: 1, excess: 8, label: <a>),
    vertex(name: $b$, height: 0, excess: 12, label: <b>),
    vertex(name: $t$, height: 0, excess: 0, label: <t>),
  ),
  (
    (<a>, <s>, 10),
    (<b>, <s>, 10, -20deg),
    (<b>, <a>, 2),
    (<a>, <t>, 4, 30deg, true),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 0, label: <s>),
    vertex(name: $a$, height: 1, excess: 4, label: <a>),
    vertex(name: $b$, height: 0, excess: 12, label: <b>),
    vertex(name: $t$, height: 0, excess: 4, label: <t>),
  ),
  (
    (<a>, <s>, 10),
    (<b>, <s>, 10, -20deg),
    (<b>, <a>, 2),
    (<t>, <a>, 4, -30deg),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 0, label: <s>),
    vertex(name: $a$, height: 5, excess: 4, label: <a>),
    vertex(name: $b$, height: 0, excess: 12, label: <b>),
    vertex(name: $t$, height: 0, excess: 4, label: <t>),
  ),
  (
    (<a>, <s>, 10, 0deg, true),
    (<b>, <s>, 10),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 4, label: <s>),
    vertex(name: $a$, height: 5, excess: 0, label: <a>),
    vertex(name: $b$, height: 0, excess: 12, label: <b>),
    vertex(name: $t$, height: 0, excess: 4, label: <t>),
  ),
  (
    (<s>, <a>, 4, 20deg),
    (<a>, <s>, 6, 20deg),
    (<b>, <s>, 10),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<b>, <t>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 4, label: <s>),
    vertex(name: $a$, height: 5, excess: 0, label: <a>),
    vertex(name: $b$, height: 1, excess: 12, label: <b>),
    vertex(name: $t$, height: 0, excess: 4, label: <t>),
  ),
  (
    (<s>, <a>, 4, 20deg),
    (<a>, <s>, 6, 20deg),
    (<b>, <s>, 10),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<b>, <t>, 9, 0deg, true)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 4, label: <s>),
    vertex(name: $a$, height: 5, excess: 0, label: <a>),
    vertex(name: $b$, height: 1, excess: 3, label: <b>),
    vertex(name: $t$, height: 0, excess: 13, label: <t>),
  ),
  (
    (<s>, <a>, 4, 20deg),
    (<a>, <s>, 6, 20deg),
    (<b>, <s>, 10),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<t>, <b>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 4, label: <s>),
    vertex(name: $a$, height: 5, excess: 0, label: <a>),
    vertex(name: $b$, height: 5, excess: 3, label: <b>),
    vertex(name: $t$, height: 0, excess: 13, label: <t>),
  ),
  (
    (<s>, <a>, 4, 20deg),
    (<a>, <s>, 6, 20deg),
    (<b>, <s>, 10, 30deg, true),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<t>, <b>, 9)
  )
),

draw-push-relabel-stage(
  (
    vertex(name: $s$, height: 4, excess: 7, label: <s>),
    vertex(name: $a$, height: 5, excess: 0, label: <a>),
    vertex(name: $b$, height: 5, excess: 0, label: <b>),
    vertex(name: $t$, height: 0, excess: 13, label: <t>),
  ),
  (
    (<s>, <a>, 4, 20deg),
    (<a>, <s>, 6, 20deg),
    (<s>, <b>, 3, -50deg),
    (<b>, <s>, 7, 30deg),
    (<b>, <a>, 2),
    (<t>, <a>, 4),
    (<t>, <b>, 9)
  )
)
)
