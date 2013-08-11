function tvgen_fft_r22sdf (N, tfBits, num_blocks)

  tv = load (sprintf ('../unittests/tvin/fft%d_tv0.dat', N));

  for m = 1:N:num_blocks*N
    x = tv(m:m+N-1,1) + 1j*tv(m:m+N-1,2);

    X = zeros (N,1);
    for k = 1:N
      for n = 1:N
        nk   = (n-1)*(k-1);
        w    = exp(-1j*2*pi*nk/N);
        w    = round (w * 2^(tfBits-1)) / 2^(tfBits-1);
        X(k) = X(k) + x(n) * w;
      end
    end

    for n = 1:N
      k = n-1;
      k = bi2de (fliplr (de2bi (k, log2(N))));
      fprintf ('%4d: X[%4d] => %12.2f %12.2f\n', floor(m/N),...
                                                 k,...
                                                 real(X(k+1)),...
                                                 imag(X(k+1)));
    end
    fprintf ('\n');
  end
end