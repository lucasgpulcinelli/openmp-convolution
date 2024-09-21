import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import sys
import subprocess

sns.set_style("darkgrid")

if len(sys.argv) != 5:
    print(f"usage: {sys.argv[0]} executable repetitions max_threads input")
    sys.exit(0)

executable = sys.argv[1]
repetitions = int(sys.argv[2])
max_threads = int(sys.argv[3])
code_input = sys.argv[4]

execution_times = np.zeros((repetitions, max_threads))

for i in range(repetitions):
    for j in range(max_threads):
        print(f"executing time {i+1} with {j+1} processors")
        p = subprocess.run(
            [executable, "true", str(j + 1)],
            input=code_input,
            capture_output=True,
            text=True,
        )

        execution_times[i, j] = float(p.stdout.split("\n")[0])


x = np.arange(1, max_threads + 1)

speedup = np.average(execution_times[:, 0]) / execution_times

std = np.std(speedup, axis=0)
avg = np.average(speedup, axis=0)

sns.lineplot(x=x, y=avg)
plt.fill_between(x, avg + std, avg - std, color="b", alpha=0.15)
sns.lineplot(x=x, y=x)
plt.xticks(x)
plt.title("speedup")
plt.savefig("/tmp/speedup.png")
plt.show()

processor_div = np.array([np.arange(max_threads) + 1 for _ in range(repetitions)])
efficiency = speedup / processor_div

std_ef = np.std(efficiency, axis=0)
avg_ef = np.average(efficiency, axis=0)

sns.lineplot(x=x, y=avg_ef)
plt.fill_between(x, avg_ef + std_ef, avg_ef - std_ef, color="b", alpha=0.15)
plt.xticks(x)
plt.title("efficiency")
plt.savefig("/tmp/efficiency.png")
plt.show()
