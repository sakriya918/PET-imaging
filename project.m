clear; close all;

xd = 128;
num_iterations = 100;
num_angles = 180;
angles = linspace(0, 180, num_angles);
azi_angles = 1:1:180; % Define globally

true_object = abs(phantom(xd));

figure;

subplot(2, 2, 1);
imshow(true_object, [0 max(true_object(:))], 'XData', [-64 64], 'YData', [-64 64]);
axis on;
axis([-64 64 -64 64]);
set(gca, 'YDir', 'normal');
title('Phantom (Brain Model)');
hold on;

subplot(2, 2, 2);
imshow(zeros(xd), 'XData', [-64 64], 'YData', [-64 64]);
axis on;
axis([-64 64 -64 64]);
set(gca, 'YDir', 'normal');
title('Photon Pair Line');
hold on;

subplot(2, 2, 3);
sinogram = zeros(180, 185);
imagesc(linspace(-92.5, 92.5, 185), linspace(0, pi, 180), sinogram);
colormap([1 1 1; 0 0 0]);
axis on;
axis([-92.5 92.5 0 pi]);
set(gca, 'YDir', 'normal');
xlabel('s (Perpendicular distance)');
ylabel('phi (Angle in radians)');
title('Sinogram');
grid on;
hold on;
pbaspect([1 1 1]);

subplot(2, 2, 4);
title('Forward Projection of Final Sinogram');
hold on;

for it = 1:num_iterations
    while true
        x = randi([1, xd]);
        y = randi([1, xd]);
        if true_object(y, x) > 0
            break;
        end
    end

    x_centered = x - xd / 2;
    y_centered = y - xd / 2;

    angle_idx = randi([1, num_angles]);
    theta = angles(angle_idx);

    x2 = round(x_centered + 2 * xd * cosd(theta));
    y2 = round(y_centered + 2 * xd * sind(theta));
    x3 = round(x_centered - 2 * xd * cosd(theta));
    y3 = round(y_centered - 2 * xd * sind(theta));

    [x_line1, y_line1] = bresenham_line(x_centered, y_centered, x2, y2);
    [x_line2, y_line2] = bresenham_line(x_centered, y_centered, x3, y3);
    x_line = [x_line1; x_line2];
    y_line = [y_line1; y_line2];
    valid_idx = x_line >= -64 & x_line <= 64 & y_line >= -64 & y_line <= 64;
    x_line = x_line(valid_idx);
    y_line = y_line(valid_idx);

    A = sind(theta);
    B = -cosd(theta);
    C = -(A * x_centered + B * y_centered);

    s_unsigned = abs(C) / sqrt(A^2 + B^2);

    rho_x = -A * C / (A^2 + B^2);
    rho_y = -B * C / (A^2 + B^2);

    phi = mod(atan2d(rho_y, rho_x), 180);

    if rho_y >= 0
        s = s_unsigned;
    else
        s = -s_unsigned;
    end

    subplot(2, 2, 1);
    imshow(true_object, [0 max(true_object(:))], 'XData', [-64 64], 'YData', [-64 64]);
    axis on;
    axis([-64 64 -64 64]);
    set(gca, 'YDir', 'normal');
    title('Phantom (Brain Model)');
    hold on;
    plot(x_centered, y_centered,'r.', 'MarkerSize', 5);
    hold off;

    subplot(2, 2, 2);
    imshow(zeros(xd), 'XData', [-64 64], 'YData', [-64 64]);
    axis on;
    axis([-64 64 -64 64]);
    set(gca, 'YDir', 'normal');
    title('Photon Pair Line');
    hold on;
    plot(x_line, y_line, 'g.', 'MarkerSize', 2);
    plot([0 rho_x], [0 rho_y], 'w-', 'LineWidth', 0.5);
    hold off;

    subplot(2, 2, 3);
    plot(s, deg2rad(phi), 'w.', 'MarkerSize', 3);
    drawnow;
    fprintf('Iteration %d: s = %.2f, phi = %.2f degrees\n', it, s, phi);

    sinogram(angle_idx, :) = sinogram(angle_idx, :) + histcounts(s, linspace(-92.5, 92.5, 186));
end

% Forward Projection of Final Sinogram
fp = radon(sinogram, azi_angles);
subplot(2, 2, 4);
imshow(fp', [0 max(fp(:))]);
title('Forward Projection of Final Sinogram');
drawnow;

function [x, y] = bresenham_line(x1, y1, x2, y2)
    x = [];
    y = [];
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    sx = sign(x2 - x1);
    sy = sign(y2 - y1);

    if dy <= dx
        err = dx / 2;
        while x1 ~= x2
            x = [x; x1];
            y = [y; y1];
            err = err - dy;
            if err < 0
                y1 = y1 + sy;
                err = err + dx;
            end
            x1 = x1 + sx;
        end
    else
        err = dy / 2;
        while y1 ~= y2
            x = [x; x1];
            y = [y; y1];
            err = err - dx;
            if err < 0
                x1 = x1 + sx;
                err = err + dy;
            end
            y1 = y1 + sy;
        end
    end
    x = [x; x2];
    y = [y; y2];
end