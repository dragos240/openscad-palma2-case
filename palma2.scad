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


module rounded_corners_rect(w, l, r) {
  square([w-r/2, l-r/2], center=true);
  difference() {
      // Main rectangle with rounded corners
      offset(r=r)
          square([w - 2*r, l - 2*r], center=true);
      // Cut out the corners to keep radius consistent
      offset(delta=-r)
          square([w, l], center=true);
  }
}


module palma(inner_w, inner_l, h, r, pad, padding, printBackplate) {
  w = inner_w+padding;
  l = inner_l+padding;
  gen_h = 50;
  gen_l = 20;

  module camera(offsets, dims) {
    color("magenta")
    translate([offsets[0], offsets[1], -5])
    rounded_cube([dims[0], dims[1], 10], padding);
  }

  module usb(offsets, length) {
    color("red")
    translate([offsets[0], offsets[1], gen_h/2-pad])
    // This rotate is just so that the corners of the USB cutout are round
    rotate([90, 0, 0])
    rounded_cube([length, gen_h, 10], 2);
  }

  module bot_mic(x_offset, length) {
    color("red")
    translate([(inner_w-x_offset)/2 + x_offset/2, 5, gen_l/2+1])
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
    translate([inner_w-5, inner_l-y_offset, gen_h/2])
    rotate([0, 90, 0])
    rounded_cube([gen_h, length, gen_l], 3);
  }

  module smart_button(y_offset, length) {
    color("magenta")
    translate([-10, inner_l-y_offset, gen_h/2])
    rotate([0, 90, 0])
    rounded_cube([gen_h, length, gen_l], 3);
  }

  module top_speaker(x_offset, diameter) {
    color("magenta")
    translate([x_offset, inner_l-5, h/2])
    rotate([-90, 0, 0])
    cylinder(r = diameter/2, 10);
  }

  module backplate() {
    translate([-padding, 0, -1.2])
      linear_extrude(padding-pad*2)
        translate([w/2, l/2])
          rounded_corners_rect(inner_w-pad*4, inner_l, r);
  }

  module test_mask() {
    translate([-7, -20, -5])
      cube([w+10, l, h+10]);
  }

  difference() {
    union() {
      // bottom
      top(inner_w-pad*2, r = r);
      // left
      translate([0, inner_l-r, 0])
        rotate([0, 0, 00])
        rotate([90, 0, 0])
        linear_extrude(inner_l-2*r)
        edge();
      //right
      translate([w-padding*2+pad, r, 0])
        rotate([0, 0, 180])
        rotate([90, 0, 0])
        linear_extrude(inner_l-2*r)
        edge();
      // top
      translate([0, inner_l, 0])
        mirror([0, 1, 0])
        top(w-padding*2+pad, r = r);
      if (printBackplate == true) {
        backplate();
      }
    }
    union() {
      //camera
      camera([inner_w-14.5, inner_l-33], [9, 40]);
      // usb
      usb([inner_w/2, 5], 15);
      // bottom microphone
      bot_mic(55, 55+4);
      // lower sides
      lower_sides(inner_l/2, 150);
      // volume+power
      vol_power(48, 40);
      // smart button
      smart_button(52, 12);
      // speaker
      top_speaker(inner_w-31.5, 3.5);
    }
    // test_mask();
  }
}

// Load profile of the edge
module edge() {
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

// Controls the "smoothness" of rounded corners (number of segments)
$fn=25;

padding = 1.5;
inner_w = 80;
inner_l = 160;
h = 9.3;
r = 6.0;
pad = 0.5;

// Set printBackplate to "false" if you want a bumper case instead
palma(inner_w, inner_l, h, r, pad, padding, printBackplate=true);
