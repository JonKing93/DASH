
# Scientific publications
DASH has been used to implement a number of recent scientific publications. Find them here:


<ul id="showcase">
{% for paper in site.data.showcase %}

<li class="showcase-paper">
  <div class="showcase-title">
    <a href="{{paper.link}}">{{paper.title}}</a>
  </div>

  <div class="showcase-authors">
    {{paper.authors}}
  </div>

  <div class="showcase-pub">
    {{paper.journal}} {{paper.volume}}({{paper.number}})
  </div>

{% endfor %}
<ul>
