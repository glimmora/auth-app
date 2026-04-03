package com.authvault.authapp.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.authvault.authapp.data.Account
import com.authvault.authapp.databinding.ItemAccountBinding
import com.authvault.authapp.crypto.TotpEngine
import android.os.CountDownTimer
import android.graphics.Color
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context

class AccountAdapter(
    private val context: Context,
    private val onAccountClick: (Account) -> Unit
) : ListAdapter<Account, AccountAdapter.AccountViewHolder>(AccountDiffCallback()) {

    private val timers = mutableMapOf<Long, CountDownTimer>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AccountViewHolder {
        val binding = ItemAccountBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return AccountViewHolder(binding)
    }

    override fun onBindViewHolder(holder: AccountViewHolder, position: Int) {
        val account = getItem(position)
        holder.bind(account)
    }

    override fun onViewRecycled(holder: AccountViewHolder) {
        super.onViewRecycled(holder)
        timers[holder.adapterPosition.toLong()]?.cancel()
    }

    inner class AccountViewHolder(
        private val binding: ItemAccountBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(account: Account) {
            binding.tvIssuer.text = account.issuer
            binding.tvLabel.text = account.label
            
            // Show offset indicator
            if (account.offset != 0) {
                binding.tvOffset.text = "Offset: ${account.offset}s"
                binding.tvOffset.visibility = android.view.View.VISIBLE
            } else {
                binding.tvOffset.visibility = android.view.View.GONE
            }

            updateCode(account)

            val period = account.period
            val remaining = TotpEngine.getRemainingSeconds(period)

            binding.progressCircular.max = period
            binding.progressCircular.progress = remaining

            updateTimerColor(remaining, period)

            timers[account.id]?.cancel()
            val timer = object : CountDownTimer(remaining * 1000L, 1000) {
                override fun onTick(millisUntilFinished: Long) {
                    val seconds = (millisUntilFinished / 1000).toInt()
                    binding.progressCircular.progress = seconds
                    binding.tvTimer.text = "$seconds"
                    updateTimerColor(seconds, period)
                    
                    if (seconds == period - 1 || seconds == 0) {
                        updateCode(account)
                    }
                }

                override fun onFinish() {
                    updateCode(account)
                    start()
                }
            }.start()

            timers[account.id] = timer

            binding.root.setOnClickListener {
                copyToClipboard(account.getCurrentCode())
                onAccountClick(account)
            }
        }

        private fun updateCode(account: Account) {
            binding.tvCode.text = account.getCurrentCode().let { code ->
                if (code.length == 6) {
                    "${code.take(3)} ${code.takeLast(3)}"
                } else {
                    code
                }
            }
        }

        private fun updateTimerColor(remaining: Int, period: Int) {
            val color = when {
                remaining <= 5 -> Color.RED
                remaining <= 10 -> Color.rgb(255, 165, 0) // Orange
                else -> Color.GREEN
            }
            binding.progressCircular.setIndicatorColor(color)
            binding.tvTimer.setTextColor(color)
        }

        private fun copyToClipboard(text: String) {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("OTP Code", text)
            clipboard.setPrimaryClip(clip)
            
            android.widget.Toast.makeText(
                context,
                "Code copied to clipboard",
                android.widget.Toast.LENGTH_SHORT
            ).show()
            
            android.os.Handler(context.mainLooper).postDelayed({
                clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
            }, 30000) // Auto-clear after 30 seconds
        }
    }

    class AccountDiffCallback : DiffUtil.ItemCallback<Account>() {
        override fun areItemsTheSame(oldItem: Account, newItem: Account): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Account, newItem: Account): Boolean {
            return oldItem == newItem
        }
    }
}
