(function($) {
    $(document).ready(function() {
	
	$('#anim_plot').scianimator({
	    'images': ['../results/anim_dir/anim_plot1.png', '../results/anim_dir/anim_plot2.png', '../results/anim_dir/anim_plot3.png', '../results/anim_dir/anim_plot4.png', '../results/anim_dir/anim_plot5.png', '../results/anim_dir/anim_plot6.png', '../results/anim_dir/anim_plot7.png', '../results/anim_dir/anim_plot8.png', '../results/anim_dir/anim_plot9.png'],
	    'width': 480,
	    'delay': 250,
	    'loopMode': 'loop'
	});
	$('#anim_plot').scianimator('play');
    });
})(jQuery);
