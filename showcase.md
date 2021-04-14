
# Scientific publications
DASH has been used to implement a number of recent scientific publications. Find them here:


<ul id="showcase">
{% for paper in site.data.showcase %}

<li class="showcase_paper">
  <div>
    <a class="showcase_title" href="{{paper.link}}">{{paper.title}}</a>
  </div>

  <div class="showcase_authors">
    {{paper.authors}}
  </div>

  <div class="showcase_pub">
    {{paper.journal}} {{paper.volume}}({{paper.number}})
  </div>
</li>

{% endfor %}
<ul>
