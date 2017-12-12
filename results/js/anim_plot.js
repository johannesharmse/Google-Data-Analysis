(function($) {
    $(document).ready(function() {
	
	$('#anim_plot').scianimator({
	    'images': ['anim_dir/anim_plot1.png', 'anim_dir/anim_plot2.png', 'anim_dir/anim_plot3.png', 'anim_dir/anim_plot4.png', 'anim_dir/anim_plot5.png', 'anim_dir/anim_plot6.png', 'anim_dir/anim_plot7.png', 'anim_dir/anim_plot8.png', 'anim_dir/anim_plot9.png', 'anim_dir/anim_plot10.png', 'anim_dir/anim_plot11.png'],
	    'width': 720,
	    'delay': 1000,
	    'loopMode': 'loop'
	});
	$('#anim_plot').scianimator('play');
    });
})(jQuery);
