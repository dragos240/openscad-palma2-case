module pie_piece(h, r, angle = 90, start_angle = 0) {
    rotate([0, 0, start_angle])
    rotate_extrude(angle = angle)
    square([r, h]);
}

module rounded_cube(dim, r) {
    dim_cube = dim - [2*r, 0, 0];
    translate([-0.5*dim_cube[0], -0.5*dim_cube[1], 0])
        cube(dim_cube);
    translate([0.5*dim[0]-0.5*r, 0, dim[2]*0.5])
        cube([r, dim[1]-2*r, dim[2]], center = true);
    translate([-0.5*dim[0]+0.5*r, 0, dim[2]*0.5])
        cube([r, dim[1]-2*r, dim[2]], center = true);
    translate([(0.5*dim[0]-r), (0.5*dim[1]-r), 0])
        pie_piece(dim[2], r);
    translate([-(0.5*dim[0]-r), (0.5*dim[1]-r), 0])
        pie_piece(dim[2], r, start_angle = 90);
    translate([-(0.5*dim[0]-r), -(0.5*dim[1]-r), 0])
        pie_piece(dim[2], r, start_angle = 90*2);
    translate([(0.5*dim[0]-r), -(0.5*dim[1]-r), 0])
        pie_piece(dim[2], r, start_angle = 90*3);
}


module case_base(w, l, h, r, pad, padding) {
  lin = l-2*padding+pad;
  win = w-2*padding+pad;
  gen_h = 50;
  gen_l = 20;

  module camera(offsets, dims) {
    color("magenta")
    translate([offsets[0], offsets[1], -5])
    rounded_cube([dims[0], dims[1], 10], padding);
  }

  module usb(offsets, length) {
    color("red")
    translate([offsets[0], offsets[1], gen_h/2])
    // This rotate is just so that the corners of the USB cutout are round
    rotate([90, 0, 0])
    rounded_cube([length, gen_h, 10], 2);
  }

  module bot_mic(x_offset, length) {
    color("red")
    translate([(win-x_offset)/2 + x_offset/2, 5, gen_l/2+1])
    rotate([90, 0, 0])
    rounded_cube([length, gen_l, 10], 3);
  }

  module lower_sides(y_offset, length) {
    color("red")
    translate([-10, y_offset, h-(2.5+padding)+gen_h/2])
    rotate([0, 90, 0])
    rounded_cube([gen_h, length, w+20], 15);
  }

  module vol_power(y_offset, length) {
    color("magenta")
    translate([win-5, lin-y_offset, gen_h/2])
    rotate([0, 90, 0])
    rounded_cube([gen_h, length, gen_l], 3);
  }

  module smart_button(y_offset, length) {
    color("magenta")
    translate([-10, lin-y_offset, gen_h/2])
    rotate([0, 90, 0])
    rounded_cube([gen_h, length, gen_l], 3);
  }

  module top_speaker(x_offset, diameter) {
    color("magenta")
    translate([win-x_offset, lin-5, h/2])
    rotate([-90, 0, 0])
    cylinder(r = diameter/2, 10);
  }

  module backplate() {
    difference() {
      scale([1, 1, 0.125])
        translate([win/2, lin, 6])
          rotate([90, 0, 0])
            cylinder(r = win/2, lin-5);
      scale([1, 1, 0.125])
        translate([win/2, lin, 10])
          rotate([90, 0, 0])
            cylinder(r = win/2, lin-5);
    }
  }

  difference() {
    union() {
      // bottom
      top(win, r = r);
      // left
      translate([0, lin-r, 0])
        rotate([0, 0, 00])
        rotate([90, 0, 0])
        linear_extrude(lin-2*r)
        edge();
      //right
      translate([w-padding*2+pad, r, 0])
        rotate([0, 0, 180])
        rotate([90, 0, 0])
        linear_extrude(lin-2*r)
        edge();
      // top
      translate([0, lin, 0])
        mirror([0, 1, 0])
        top(w-padding*2+pad, r = r);
      // backplate (comment out if you want no back)
      // backplate();
    }
    union() {
      //camera
      camera([win-14, lin-33], [9, 40]);
      // usb
      usb([win/2, 5], 15);
      // bottom microphone
      bot_mic(55, 55+4);
      // lower sides
      lower_sides(lin/2, 150);
      // volume+power
      vol_power(48, 40);
      // smart button
      smart_button(52, 12);
      // speaker
      top_speaker(30.5, 3.5);
      // cut away a bit of the overhang at the bottom to be able to
      // insert the phone
      // rbot = 6.3;
      // translate([win/2-(55+4)/2,rbot-1.2,h-2.5])
      // cylinder(r = rbot, h=5);
      // translate([win/2+(55+4)/2,rbot-1.2,h-2.5])
      // cylinder(r = rbot, h=5);
    }
  }
}

// Load profile of the edge
module edge() {
  // import("side_v2.svg", convexity = 2);
  import("palma side2.svg", convexity = 2);
}

// Model top and bottom of case
module top(l = 80, r = 4) {
  translate([r, r, 0])
  rotate_extrude(angle=90)
    translate([-r, 0])
    edge();


  translate([r, 0, 0])
  rotate([0, 0, 90])
  rotate([90, 0, 0])
  linear_extrude(l-r-r)
    edge();

  translate([l-r, r, 0])
  rotate([0, 0, 90])
  rotate_extrude(angle=90)
    translate([-r, 0])
    edge();
}

$fn=25;

padding = 1.5;
w = 80 + 1.3;
l = 160 + 1.3;
h = 9.3;
r = 6.0;
pad = 0.5;

case_base(w, l, h, r, pad, padding);
