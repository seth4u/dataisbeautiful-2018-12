var barHeight = Math.ceil(height / data.length);

var div = d3.select("body").append("div")	
    .attr("class", "tooltip")				
    .style("opacity", 0)
    
svg.selectAll('rect')
  .data(data)
  .enter().append('rect')
    .attr('width', function(d) { return d.days * width / 365; })
    .attr('height', barHeight/1.1)
    .attr('y', function(d, i) { 
      return (d.year - options.minYear) * barHeight; 
    })
    .attr('x', function(d) { return d.start_day * width / 365; })
    .attr('fill', function(d, i) { return "#0248ee"; })
    .on("mouseover", function(d) {
      d3.select(this).
        attr("fill", function() {
          return "#eea702";
        });
      div.style("opacity", 0.97);		
      div.html(
        "<h4>Season " + d.year + "</h4><small>" + 
        d.date_closed + " to "  + d.date_opened + "</small></br></br>" + 
        "Days Frozen: <b>" + d.days + "</b>")	
         .style("left", (d3.event.pageX) + "px")		
         .style("top", (d3.event.pageY - 28) + "px");	
    })
    .on("mouseout", function(d) {
        d3.select(this).
          attr("fill", function() {
            return "#0248ee";
          });
        div.style("opacity", 0);
    });