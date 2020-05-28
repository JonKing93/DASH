Glossary test

{% for item in site.data.glossary %} 
{{item.name}}: {{item.description}} 
{% endfor %}
